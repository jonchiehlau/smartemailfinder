class Person
  attr_accessor :first_name, :last_name, :domain, :matched_permutations

  def initialize(first_name, last_name, domain)
    @first_name = (first_name || '').strip
    @last_name = (last_name || '').strip
    @domain = domain_host(domain)
    @matched_permutations = []

    generate_possible_permutations
  end

  def pop_permutations(max_count)
    return [] if matched_permutations.any?
    result = []

    while result.size == 0 && @possible_permutations.values.flatten.any?

      (1..3).each do |batch_no|
        if @possible_permutations["batch_#{batch_no}".to_sym].any?
          batch = @possible_permutations["batch_#{batch_no}".to_sym]
          while result.size < max_count && batch.any?
            result << batch.shift
          end
          break
        end
      end
    end
    result
  end

  private

  def generate_possible_permutations
    @possible_permutations = {}
    batch_1 = []
    batch_1 << "#{first_name}@#{domain}" unless first_name.empty?
    batch_1 << "#{last_name}@#{domain}" unless last_name.empty?
    batch_1 << "#{first_name}#{last_name}@#{domain}" unless (first_name.empty? || last_name.empty?)
    batch_1 << "#{first_name}.#{last_name}@#{domain}" unless (first_name.empty? || last_name.empty?)
    @possible_permutations[:batch_1] = batch_1

    batch_2 = []
    batch_2 << "#{first_name}#{last_name[0]}@#{domain}" unless last_name.empty?
    batch_2 << "#{first_name}.#{last_name[0]}@#{domain}" unless last_name.empty?
    batch_2 << "#{first_name[0]}#{last_name}@#{domain}" unless first_name.empty?
    @possible_permutations[:batch_2] = batch_2

    batch_3 = []
    batch_3 << "#{first_name}_#{last_name}@#{domain}" unless (first_name.empty? || last_name.empty?)
    batch_3 << "#{first_name}_#{last_name[0]}@#{domain}" unless (first_name.empty? || last_name.empty?)
    batch_3 << "#{first_name}_#{last_name}@#{domain}" unless (first_name.empty? || last_name.empty?)
    @possible_permutations[:batch_3] = batch_3

  end

  def domain_host(url)
    url = "http://#{url}" if URI.parse(url).scheme.nil?
    host = URI.parse(url).host.downcase
    host.start_with?('www.') ? host[4..-1] : host
  end

end