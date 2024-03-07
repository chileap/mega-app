class ChatgptClient
  attr_reader :client

  def initialize
    @client = OpenAI::Client.new
  end

  def create_completion(prompt)
    puts "Prompt: #{prompt}"
    response = client.completions(
      parameters: {
        model: "gpt-3.5-turbo", # gpt-3.5-turbo is
        prompt: prompt,
        max_tokens: 500, # 500 is the maximum words
        temperature: 0.5,
        top_p: 0.2
      }
    )
    puts "getting result"
    if response['error'].present?
      raise response['error']
      return []
    end
    response.dig("choices", 0, "text").split("\n").reject { |text| text.empty? }
  rescue => e
    puts "Error: #{e.message}"
    Rails.logger.error "Error: #{e.message}"
    raise "Error: #{e.message}"
  end
end
