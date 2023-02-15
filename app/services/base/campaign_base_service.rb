class Base::CampaignBaseService
  pattr_initialize [:campaign!]

  def perform
    raise "Invalid campaign #{campaign.id}" if invalid_campagin?
    raise 'Completed Campaign' if campaign.completed?

    # marks campaign completed so that other jobs won't pick it up
    campaign.completed!

    audience_label_ids = campaign.audience.select { |audience| audience['type'] == 'Label' }.pluck('id')
    audience_labels = campaign.account.labels.where(id: audience_label_ids).pluck(:title)
    process_audience(audience_labels)
  end

  private

  delegate :inbox, to: :campaign
  delegate :channel, to: :inbox

  def invalid_campagin?
    raise 'this method must be overriden'
  end

  def process_audience(_audience_labels)
    raise 'this method must be overriden'
  end
end