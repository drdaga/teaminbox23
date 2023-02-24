require 'uri'
class Integrations::Dialogflow::ProcessorService
  pattr_initialize [:event_name!, :hook!, :event_data!]

  def perform
    message = event_data[:message]
    return if message.private?
    return unless processable_message?(message)
    return unless message.conversation.pending?

    content = message_content(message)
    response = get_dialogflow_response(message.conversation.contact_inbox.source_id, content) if content.present?
    process_response(message, response) if response.present?
  end

  private

  def message_content(message)
    # TODO: might needs to change this to a way that we fetch the updated value from event data instead
    # cause the message.updated event could be that that the message was deleted

    return message.content_attributes['submitted_values']&.first&.dig('value') if event_name == 'message.updated'

    message.content
  end

  def processable_message?(message)
    # TODO: change from reportable and create a dedicated method for this?
    return unless message.reportable?
    return if message.outgoing? && !processable_outgoing_message?(message)

    true
  end

  def processable_outgoing_message?(message)
    event_name == 'message.updated' && ['input_select'].include?(message.content_type)
  end

  def get_dialogflow_response(session_id, message)
    Google::Cloud::Dialogflow.configure { |config| config.credentials = hook.settings['credentials'] }
    session_client = Google::Cloud::Dialogflow.sessions
    session = session_client.session_path project: hook.settings['project_id'], session: session_id
    query_input = { text: { text: message, language_code: 'en-US' } }
    session_client.detect_intent session: session, query_input: query_input
  end

  def process_response(message, response)
    fulfillment_messages = response.query_result['fulfillment_messages']
    fulfillment_messages.each do |fulfillment_message|
      content_params = generate_content_params(fulfillment_message)
      if content_params['action'].present?
        process_action(message, content_params['action'])
      else
        create_conversation(message, content_params)
      end
    end
  end

  def generate_content_params(fulfillment_message)

    return media_content(fulfillment_message) if fulfillment_message['platform'] == :ACTIONS_ON_GOOGLE
    #return media_content(fulfillment_message) if fulfillment_message['basic_card'].present?


    text_response = fulfillment_message['text'].to_h
    content_params = { content: text_response[:text].first } if text_response[:text].present?
    content_params ||= fulfillment_message['payload'].to_h
    content_params
  end

  def media_content(fulfillment_message)

    {
      content: fulfillment_message['basic_card']['title'],
      content_attributes: fulfillment_message['basic_card']['image'].to_h,
      content_type: 'media',
    }
  end
 

  def attachment(content_params, message)
    if content_params[:content_attributes][:accessibility_text] != 'document' 
  
    url = content_params[:content_attributes][:image_uri]
    filename = File.basename(URI.parse(url).path)
    file = URI.parse(url).open
    attachment = message.attachments.build(account_id: message.account_id)
    attachment.file.attach(io: file, filename: filename )
    attachment.file_type = content_params[:content_attributes][:accessibility_text]
    attachment

    else
      url = content_params[:content_attributes][:image_uri]
      filename = File.basename(URI.parse(url).path)
      file = URI.parse(url).open
      attachment = message.attachments.build(account_id: message.account_id)
      attachment.file.attach(io: file, filename: filename )
      attachment.file_type = 'file'
      attachment
    end
  end

  def interactive_message?(content_params)
      content_params['content_type'] == 'button' ||
      content_params['content_type'] == 'interactive' ||
      content_params['content_type'] == 'list'
  
  end

  def create_conversation(message, content_params)
    return if content_params.blank?

    content_params['content_type'] = 'interactive' if interactive_message?(content_params)
    logger = Logger.new(STDOUT)
    logger.info("dialogflow fullfillment message")
    logger.info(content_params['content_attributes'])

    conversation = message.conversation
    m = conversation.messages.new(content_params.merge({ message_type: :outgoing, account_id: conversation.account_id,
                                                         inbox_id: conversation.inbox_id }))

                                                     


    m.attachments << attachment(content_params, message) if m.media?
    m.save!
  end

  def process_action(message, action)
    case action
    when 'handoff'
      message.conversation.open!
    when 'resolve'
      message.conversation.resolved!
    end
  end
end