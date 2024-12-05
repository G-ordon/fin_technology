defmodule FinTech.SMSNotifications do
  @api_url "https://api.africastalking.com/version1/messaging"

  # Using Application.compile_env/3 instead of Application.get_env/2
  @username Application.compile_env(:fin_tech, :africastalking)[:username]
  @api_key Application.compile_env(:fin_tech, :africastalking)[:api_key]

  def send_sms(phone_number, message) do
    body = URI.encode_query(%{
      "username" => @username,
      "to" => phone_number,
      "message" => message
    })

    headers = [
      {"apiKey", @api_key},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    HTTPoison.post(@api_url, body, headers)
  end
end
