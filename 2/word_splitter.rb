class WordSplitter
  def initialize(dictionary)
    @dictionary = dictionary.to_set
    @word_lengths = @dictionary.map(&:length).uniq.sort.reverse
  end

  def can_split?(s)
    n = s.length
    dp = Array.new(n + 1, false)
    dp[0] = true

    (1..n).each do |i|
      @word_lengths.each do |length|
        next if i < length

        start_index = i - length
        if dp[start_index] && @dictionary.include?(s[start_index, length])
          dp[i] = true
          break
        end
      end
    end

    dp[n]
  end
end
