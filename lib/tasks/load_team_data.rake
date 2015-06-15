namespace :load_team_data do
  desc "Load 64 teams"
  task load_teams_for_team_db: :environment do

    new_data_call = SportradarApi.new

    team_data_hash = new_data_call.get_ncaa_tournament_data

    team_data_rounds_array = team_data_hash[:rounds]

    team_data_2nd_round = team_data_rounds_array[1]

    team_data_2nd_round_regoins = team_data_2nd_round[:bracketed]

    team_data = []
    team_data_2nd_round_regoins.each do |region|
      region[:games].each do |game|
        game[:home].merge(region: region[:name])
        game[:away].merge(region: region[:name])
        team_data << game[:home]
        team_data << game[:away]
      end
    end
    teams_added_count = 0
    team_data.each do |team|
      Team.create!(name: team[:name], seed: team[:seed], region: team[:region], points_per_share: (16*(1 + rand)/team[:seed]).round(2))
      puts "added Team #{team[:name]}"
      teams_added_count += 1
    end

    puts "-"*100
    puts "#{teams_added_count} Teams added"

  end

end
