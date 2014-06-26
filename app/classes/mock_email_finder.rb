class MockEmailFinder
  def initialize(persons)
    @persons = persons
  end

  def find_emails
    @persons.each do |person|
      person.matched_permutations << {
          :email => "test_email@facebook.com",
        :twitter => {:username => "twitter_username", :url => "twitter_url"},
        :facebook => {:username => "facebook_username", :url => "facebook_url"},
        :linked_in => {:username => "linked_in_username", :url => "linked_in_url"}
      }
    end

    @persons.reject{|p| p.matched_permutations.empty?}
  end
end