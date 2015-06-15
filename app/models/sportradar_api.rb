class SportradarApi

  def initialize
    @conn = Faraday.new
  end

    def get_ncaa_tournament_data
    response = @conn.get "http://api.sportradar.us/ncaamb-t3/tournaments/83c03d12-e03b-4f71-846c-5d42ba90eeb1/schedule.json?api_key=2czyeee4qe2bpyzapchh2m7q"
    JSON.parse(response.body, symbolize_names: true)
  end
end
