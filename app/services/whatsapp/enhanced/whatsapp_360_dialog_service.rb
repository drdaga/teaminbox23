class Whatsapp::Enhanced::Whatsapp360DialogService < Whatsapp::Providers::Whatsapp360DialogService
  private

  def template_body_parameters(template_info)
    {
      name: template_info[:name],
      namespace: template_info[:namespace],
      language: {
        policy: 'deterministic',
        code: template_info[:lang_code]
      },
      components: template_info[:components]
    }
  end
end