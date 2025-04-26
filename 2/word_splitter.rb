class WordSplitter
  def initialize(dictionary)
    @dictionary = dictionary.to_set.freeze
    @word_lengths = @dictionary.map(&:length).uniq.sort.reverse.freeze
  end

  def can_split?(string)
    string_length = string.length
    helper = Array.new(string_length + 1, false)
    helper[0] = true

    (1..string_length).each do |i|
      @word_lengths.each do |word_length|
        next if i < word_length

        start_index = i - word_length
        next unless helper[start_index]
        next unless @dictionary.include?(string[start_index, word_length])

        helper[i] = true
        break
      end
    end

    helper[string_length]
  end
end
