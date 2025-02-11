class TriggerScheduledItemsJob < ApplicationJob
  queue_as :scheduled_jobs

  def perform
    # trigger the scheduled campaign jobs
    Campaign.where(campaign_type: [:one_off, :whatsapp],
      campaign_status: :active).where(scheduled_at: 3.days.ago..Time.current).all.each do |campaign|
Campaigns::TriggerOneoffCampaignJob.perform_later(campaign)
    end

    # Job to reopen snoozed conversations
    Conversations::ReopenSnoozedConversationsJob.perform_later

    # Job to auto-resolve conversations
    Account::ConversationsResolutionSchedulerJob.perform_later

    # Job to sync whatsapp templates
    Channels::Whatsapp::TemplatesSyncSchedulerJob.perform_later
  end
end