class Status
  attr_reader :max, :current, :global_queue, :sessions, :cpu, :memory, :queue, :processes

  def initialize(output)
    status_command = output.match(/<.+/m).to_s
    doc = Nokogiri::XML(status_command,nil,'iso8859-1')

    @max = doc.xpath('//info/max').text.to_i
    @current = doc.xpath('//info/capacity_used').text.to_i
    @global_queue = doc.xpath('//info/get_wait_list_size').text.to_i
    @sessions = parse_sessions(doc)
    @cpu = parse_cpu(doc)
    @memory = parse_memory(doc)
    @queue = parse_queue(doc)
    @processes = parse_processes(doc)
  end

  private

  def name_clean(app_name)
    app_name.split('/').last.split('#').first
  end

  def parse_sessions(doc)
    groups = Hash.new(0)
    doc.xpath('//group').each do |group|
      group_name = name_clean(group.xpath('./name').text)
      group.xpath('.//process/sessions').each do |x|
        groups[group_name] += x.text.to_i
      end
    end
    groups
  end

  def parse_cpu(doc)
    groups = Hash.new(0)
    doc.xpath('//group').each do |group|
      group_name = name_clean(group.xpath('./name').text)
      group.xpath('.//process/cpu').each do |x|
        groups[group_name] += x.text.to_f
      end
    end
    groups
  end

  def parse_memory(doc)
    groups = Hash.new(0)
    doc.xpath('//group').each do |group|
      group_name = name_clean(group.xpath('./name').text)
      group.xpath('.//process/real_memory').each do |x|
        groups[group_name] += x.text.to_i
      end
    end
    groups
  end

  def parse_queue(doc)
    groups = Hash.new(0)
    doc.xpath('//group').each do |group|
      group_name = name_clean(group.xpath('./name').text)
      groups[group_name] = group.xpath('./get_wait_list_size').text.to_i
    end
    groups
  end

  def parse_processes(doc)
    groups = Hash.new(0)
    doc.xpath('//group').each do |group|
      group_name = name_clean(group.xpath('./name').text)
      groups[group_name] = group.xpath('./capacity_used').text.to_i
    end
    groups
  end

end
