class Whatsapp::Enhanced::SendOnWhatsappService < Whatsapp::SendOnWhatsappService
    private
  
    def send_template_message
      name, namespace, lang_code, components = processable_channel_message_template
  
      return if name.blank?
  
      message_id = channel.send_template(message.conversation.contact_inbox.source_id, {
                                           name: name,
                                           namespace: namespace,
                                           lang_code: lang_code,
                                           components: components
                                         })
      message.update!(source_id: message_id) if message_id.present?
    end
  
    def resolve_processed_params(processed_params)
      components = resolve_header_params(processed_params)
      if processed_params['body'].present?
        components << {
          'type' => 'body',
          'parameters' => processed_params['body'].map { |_, value| { type: 'text', text: value } }
        }
      end
      components
    end
  
    def resolve_header_params(processed_params)
      components = []
      if processed_params['header'].present?
        components << {
          'type' => 'header',
          'parameters' => processed_params['header'].map { |_, value| { type: 'text', text: value } }
        }
      elsif processed_params.dig('headerMedia',"link").present?
        components << {
          'type' => 'header',
          'parameters' => [
            'type' => processed_params['headerMedia']['type']&.downcase,
            processed_params['headerMedia']['type']&.to_s.downcase => {
              'link' => processed_params['headerMedia']['link']
            }
          ]
        }
      end
      components
    end
  
    def processable_channel_message_template
      if template_params.present?
        return [
          template_params['name'],
          template_params['namespace'],
          template_params['language'],
          resolve_processed_params(template_params['processed_params'])
        ]
      end
  
      # Delete the following logic once the update for template_params is stable
      # see if we can match the message content to a template
      # An example template may look like "Your package has been shipped. It will be delivered in {{1}} business days.
      # We want to iterate over these templates with our message body and see if we can fit it to any of the templates
      # Then we use regex to parse the template varibles and convert them into the proper payload
      channel.message_templates&.each do |template|
        match_obj = template_match_object(template)
        next if match_obj.blank?
  
        # we have a match, now we need to parse the template variables and convert them into the wa recommended format
        # processed_parameters = match_obj.captures.map { |x| { type: 'text', text: x } }
        components = []
        components << {
          'type' => 'body',
          'parameters' => match_obj.captures.map { |x| { type: 'text', text: x } }
        }
  
        # no need to look up further end the search
        return [template['name'], template['namespace'], template['language'], components]
      end
      [nil, nil, nil, nil]
    end
end
  