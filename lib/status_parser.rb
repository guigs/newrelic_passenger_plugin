class Status
  require 'date'

  attr_reader :max, :current, :queue, :sessions, :cpu, :process_memory, :last_used_time

  def initialize(output)
    status_command = output.match(/<.+/m).to_s
    doc = Nokogiri::XML(status_command,nil,'iso8859-1')

    @max = doc.xpath('//info/max').text.to_i
    @current = doc.xpath('//info/capacity_used').text.to_i
    @queue = doc.xpath('//info/get_wait_list_size').text.to_i
    @sessions = parse_sessions(doc)
    @cpu = parse_cpu(doc)
    @process_memory = parse_app_memory(doc)
    @last_used_time = parse_last_used(doc)
  end

  private

  def name_clean(app_name)
    if app_name.length > 45
      first_half = app_name.match('.+:').to_s
      second_half = app_name.split('/')[-1].to_s
      cleaned_name = first_half + ' ' + second_half
    else
      cleaned_name = app_name
    end
    cleaned_name
  end

  def parse_sessions(doc)
    sessions_total = 0
    doc.xpath('//process/sessions').each do |x|
      sessions_total += x.text.to_i
    end
    sessions_total
  end

  def parse_cpu(doc)
    cpu_total = 0
    doc.xpath('//process/cpu').each do |x|
      cpu_total += x.text.to_f
    end
    cpu_total
  end

  def parse_app_memory(doc)
    processes = Hash.new(0)
    doc.xpath('//process').each do |x|
      processes[name_clean(x.xpath('./command').text)] += x.xpath('./real_memory').text.to_i
    end
    processes
  end

  def parse_last_used(doc)
    processes = Hash.new(0)
    doc.xpath('//process').each_with_index do |x, index|
      unix_stamp = (x.xpath('./last_used').text.to_i / 1000000)
      elapsed = Time.now.to_i - unix_stamp
      processes[(index + 1).to_s] = elapsed
    end
    processes
  end

end
