class Whatsapp::Enhanced::WhatsappCloudService < Whatsapp::Providers::WhatsappCloudService
  private

  def template_body_parameters(template_info)
    {
      name: template_info[:name],
      language: {
        policy: 'deterministic',
        code: template_info[:lang_code]
      },
      components: template_info[:components]
    }
  end
end