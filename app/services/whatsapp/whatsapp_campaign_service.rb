class Whatsapp::WhatsappCampaignService < Base::CampaignBaseService
  private

  def invalid_campagin?
    campaign.inbox.inbox_type != 'Whatsapp' || !campaign.whatsapp?
  end

  def process_audience(audience_labels)
    campaign.account.contacts.tagged_with(audience_labels, any: true).each do |contact|
      next if contact.phone_number.blank?

      conversation = get_conversation(contact)
      conversation.messages.build(message_params).save!
    end
  end

  def get_conversation(contact)
    conversation = campaign.account.conversations.where(
      contact_id: contact.id,
      inbox_id: inbox.id
    ).last

    unless conversation
      contact_inbox = build_contact_inbox(contact)
      conversation = campaign.account.conversations.create({
                                                             inbox_id: inbox.id,
                                                             contact_id: contact.id,
                                                             contact_inbox_id: contact_inbox.id,
                                                             additional_attributes: {},
                                                             custom_attributes: {}
                                                           })
    end
    conversation
  end

  def build_contact_inbox(contact)
    ContactInboxBuilder.new(inbox_id: inbox.id, contact_id: contact.id).perform
  end

  def additional_attributes
    { additional_attributes: { template_params: campaign.trigger_rules['template_params'], campaign_id: campaign.id } }
  end

  def message_params
    {
      account_id: campaign.account.id,
      inbox_id: inbox.id,
      message_type: 'outgoing',
      content: campaign.message,
      private: false
    }.merge(additional_attributes)
  end
end