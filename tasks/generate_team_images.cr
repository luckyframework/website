require "http/client"

class GenerateTeamImages < LuckyTask::Task
  summary "generate team images"

  property(members : Array(::Members::Member)) {
    [::Members.creator] + ::Members.team_members
  }

  def call
    members.each do |member|
      puts "Downloading Avatar for #{member.fullname}"
      download_w_redirect(member, "https://github.com/#{member.github}.png", "#{member.github}.jpg")
    end
  end

  private def download_w_redirect(member, link, image_name)
    HTTP::Client.get(link) do |response|
      if response.status.success?
        File.open(Path["./public/assets/images"] / image_name, "w") do |f|
          IO.copy(response.body_io, f)
        end
      elsif !response.status.redirection?
        raise "Unexpected Status: #{response.status_code}"
      else
        download_w_redirect(member, response.headers["location"], image_name)
      end
    end
  end
end
