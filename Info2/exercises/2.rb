class LRU
  def initialize
    @list = []
  end

  def front
    @list.first
  end

  def send_back value
    @list.delete value
    @list << value
  end
end

class Cache
  WORD_LENGTH = 4

  def initialize capacity, line_length, tag_width, line_width, word_width, byte_width
    @capacity = capacity
    @line_length = line_length
    @lines = capacity / line_length
    @tag_width = tag_width
    @line_width = line_width
    @word_width = word_width
    @byte_width = byte_width

    @hit_list = []

    @cache = (1..@lines).map { |line| [{ valid: 0, tag: nil, address: nil }] }
  end

  def line_info
    "TAG #{@tag_width}, LINE #{@line_width}, WORD #{@word_width}, BYTE #{@byte_width}"
  end

  def hit address, hit
    @hit_list << { address: address, hit: hit }
  end

  def tag address
    (address & (0xFFFF << tag_offset)) >> tag_offset
  end

  def word_offset
    @byte_width
  end

  def line_offset
    word_offset + @word_width
  end

  def tag_offset
    line_offset + @line_width
  end

  def hit_list
    @hit_list.map { |info| "#{info[:address]}#{info[:hit] ? "h" : "m"}" }.join ", "
  end

  def range line, number = 0
    if line[:tag]
      start = (line[:tag] << tag_offset) + (number << line_offset)

      range = (start..start + @line_length - 1)

      "#{range.min.to_s.rjust 3}-#{range.max.to_s.rjust 3}"
    else
      " " * 7
    end
  end
end

class FullyAssociativeCache < Cache
  def initialize capacity, line_length, tag_width, line_width, word_width, byte_width
    super

    @lru = LRU.new
  end

  def read address
    tag = tag address

    (0...@lines).map do |i|
      if @cache[i].last[:tag] == tag && @cache[i].last[:valid]
        @cache[i] << { valid: 1, tag: tag, address: address }

        hit address, true

        @lru.send_back i

        return
      elsif @cache[i].last[:valid] == 0
        @cache[i] << { valid: 1, tag: tag, address: address }

        hit address, false

        @lru.send_back i

        return
      end
    end

    lru_line = @lru.front

    @cache[lru_line] << { valid: 1, tag: tag, address: address }

    hit address, false

    @lru.send_back lru_line
  end

  def to_table
    header = "| Line | Valid | Tag | Bereich | Adresse |"
    delimiter = "-" * header.length
    table = []

    table << delimiter
    table << header

    i = 1

    @cache.each do |line_history|
      table << delimiter

      line_history.each do |line|
        table << "| #{i.to_s.rjust 4} | #{line[:valid].to_s.rjust 5} | #{line[:tag].to_s.rjust 3} | #{range(line)} | #{line[:address].to_s.rjust 7} |"
      end

      i = i + 1
    end

    table << delimiter

    table
  end
end

class OneWayCache < Cache
  def read address
    tag = tag address
    line = line address

    if @cache[line].last[:valid] && @cache[line].last[:tag] == tag
      hit address, true
    else
      hit address, false
    end

    @cache[line] << { valid: 1, tag: tag, address: address }
  end

  def line address
    mask = (0...@line_width).map { |i| 1 << i }.reduce(:+)

    (address & (mask << line_offset)) >> line_offset
  end

  def to_table
    header = "| Line | Valid | Tag | Bereich | Adresse |"
    delimiter = "-" * header.length
    table = []

    table << delimiter
    table << header

    i = 0

    @cache.each do |line_history|
      table << delimiter

      line_history.each do |line|
        table << "| #{i.to_s.rjust 4} | #{line[:valid].to_s.rjust 5} | #{line[:tag].to_s.rjust 3} | #{range(line, i)} | #{line[:address].to_s.rjust 7} |"
      end

      i = i + 1
    end

    table << delimiter

    table
  end
end

class TwoWayCache < Cache
  def initialize capacity, line_length, tag_width, line_width, word_width, byte_width
    super

    @lines /= 2

    @cache = (1..@lines).map { |line| {lru: LRU.new, data: [[{ valid: 0, tag: nil, address: nil }, { valid: 0, tag: nil, address: nil }]]} }
  end

  def read address
    tag = tag address
    line = line address

    data = @cache[line][:data].last
    lru = @cache[line][:lru]

    if data[0][:valid] == 1 && data[0][:tag] == tag
      new_data = [{ valid: 1, tag: tag, address: address }, data[1]]

      lru.send_back 0
      hit address, true
    elsif data[1][:valid] == 1 && data[1][:tag] == tag
      new_data = [data[0], { valid: 1, tag: tag, address: address }]

      lru.send_back 1
      hit address, true
    else
      hit address, false

      if data[0][:valid] == 0
        new_data = [{ valid: 1, tag: tag, address: address }, data[1]]

        lru.send_back 0
      elsif data[1][:valid] == 0
        new_data = [data[0], { valid: 1, tag: tag, address: address }]

        lru.send_back 1
      else
        if lru.front == 0
          new_data = [{ valid: 1, tag: tag, address: address }, data[1]]

          lru.send_back 0
        else
          new_data = [data[0], { valid: 1, tag: tag, address: address }]

          lru.send_back 1
        end
      end
    end

    @cache[line][:data] << new_data
  end

  def line address
    mask = (0...@line_width).map { |i| 1 << i }.reduce(:+)

    (address & (mask << line_offset)) >> line_offset
  end

  def to_table
    header = "| Line |" + " Valid | Tag | Bereich | Adresse |" * 2
    delimiter = "-" * header.length
    table = []

    table << delimiter
    table << header

    i = 0

    @cache.each do |line|
        table << delimiter

        line[:data].each do |data_history|
          row = "| #{i.to_s.rjust 4} |"

          data_history.each do |data|
            row << " #{data[:valid].to_s.rjust 5} | #{data[:tag].to_s.rjust 3} | #{range(data, i)} | #{data[:address].to_s.rjust 7} |"
          end

          table << row
        end

        i = i + 1
    end

    table << delimiter

    table
  end
end

addresses = [16, 72, 20, 9, 183, 60, 19, 12, 148, 22, 8, 125, 183, 34, 47, 60]
caches = []
caches << FullyAssociativeCache.new(16, 1, 16, 0, 0 ,0)
caches << FullyAssociativeCache.new(64, 8, 13, 0, 1, 2)
caches << OneWayCache.new(128, 16, 7, 3, 2, 2)
caches << TwoWayCache.new(64, 8, 9, 2, 1, 2)

caches.each_with_index do |cache, index|
  puts "#### Teil #{index + 1} ####"
  puts

  puts cache.line_info
  puts

  addresses.each do |address|
    cache.read address
  end

  puts cache.hit_list
  puts

  puts cache.to_table
  puts

  puts
  puts
end
