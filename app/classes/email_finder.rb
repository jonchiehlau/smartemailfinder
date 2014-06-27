class EmailFinder

  MAX_BATCH_SIZE = 20

  def initialize(persons)
    @persons = persons.dup
  end

  def find_emails
    emails_to_person_map = {}
    while true
      at_least_one_email_added = true
      while emails_to_person_map.size < MAX_BATCH_SIZE && at_least_one_email_added
        at_least_one_email_added = false
        @persons.each do |person|
          permutations = person.pop_permutations(MAX_BATCH_SIZE - emails_to_person_map.size)
          permutations.each do |p|
            emails_to_person_map[p] = person
            at_least_one_email_added = true
          end
          break if emails_to_person_map.size == MAX_BATCH_SIZE
        end
      end

      break if emails_to_person_map.size == 0

      Rails.logger.info 'Will query fullcontact for the for the following emails:'
      Rails.logger.info emails_to_person_map.keys

      matched_emails, retry_emails = FullContact.batch_call(emails_to_person_map.keys)

      Rails.logger.info "Matched #{matched_emails.size} emails, to retry: #{retry_emails.size} emails."

      matched_emails.each_pair do |matched_email, social_data|
        person = emails_to_person_map[matched_email]
        person.matched_permutations << social_data.merge({:email => matched_email})
      end

      expected_emails_count = emails_to_person_map.size
      emails_to_person_map.select!{|k,v| retry_emails.include?(k)}
      if emails_to_person_map.size == expected_emails_count
        # seems like FullContact is asking us to wait on all these emails
        sleep 5
      end
      Rails.logger.info "These emails left for next call: #{emails_to_person_map.keys}"
    end

    @persons.each do |p|
      if p.matched_permutations.empty?
        p.matched_permutations << {:email => nil}
      end
    end

    @persons
  end
end