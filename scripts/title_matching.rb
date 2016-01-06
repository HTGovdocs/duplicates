require 'htph';

# Use for documents that lack good identifiers.

# Take a file of ids
file = ARGV.shift;
hdin = HTPH::Hathidata::Data.new(file).open('r');
db   = HTPH::Hathidb::Db.new();
conn = db.get_conn();
log  = HTPH::Hathilog::Log.new();
$verbose = false;

# Look up ids and make bags of words (one for title, one for publisher, etc for all categories we want)
categories  = %w[publisher title pubdate enumc];
cat_queries = {};
word_freqs  = {};
word_2_id   = {};
stop_words  = %w[
  A ADMINISTRATION AN AND ARMY AS BUREAU BY COMMISSION DEPARTMENT DEPT FEDERAL FOR GEOLOGICAL
  IN OF OFFICE ON PRINT PROGRAM PRT QUADRANGLE REPORT S SERVICE SERVICES SN SOIL STATES SURVEY
  THE TO UNITED U US
];

score_cutoff     = 0.5;
overlap_min_size = 5;

cat_sql_template = %w<
  SELECT hs.str
  FROM hathi_XXX AS hx
  JOIN hathi_str AS hs
  ON (hx.str_id = hs.id)
  WHERE hx.gd_id = ?
>.join(" ");

categories.each do |c|
  cat_queries[c] = conn.prepare(cat_sql_template.sub('XXX', c));
end

# Populate id bags
id_bags = {};
i = 0;
hdin.file.each_line do |id|
  i += 1;
  log.d("Read #{i} lines") if i % 1000 == 0;
  id.strip!;
  id = Integer(id);
  id_bags[id] = {};
  categories.each do |c|
    id_bags[id][c] = [];
    cat_queries[c].enumerate(id) do |row|
      words = row[:str].split(' ').sort.uniq - stop_words;
      # Gather word freqs while we're at it.
      words.each do |w|
        word_freqs[w] ||= 0;
        word_freqs[w]  += 1;
        word_2_id[w]  ||= {};
        # Get reverse mapping too.
        word_2_id[w][id] = 1;
      end
      id_bags[id][c] = words;
    end
  end
end
hdin.close();
conn.close();

tot_freq = 0.0;
word_freqs.values.each do |freq|
  tot_freq += freq;
end
# Inverse word/doc freq (because a word only occurs 0 or 1 times per doc, so word freq and doc freq are the same)
# would be 1 - (word_freq.to_f / tot_freq)
inv_freq    = lambda {|word| 1 - (word_freqs[word].to_f / tot_freq).round(3)};
get_words   = lambda {|id|   categories.map{|c| id_bags[id][c]}.flatten.sort.uniq};
comparisons = 0;
outputted   = 0;
hdout       = HTPH::Hathidata::Data.new("title_word_matches.tsv").open('w');

id_bags.keys.sort.each do |id|
  # Get all the words per id
  # Sort so the first word is the most relevant/rare
  words = get_words.call(id).sort_by{|w| inv_freq.call(w)}.reverse;
  # Get all ids for all words
  other_ids = words.map{|w| word_2_id[w].keys}.flatten.sort.uniq - [id];
  # Check the words for the other ids
  # So we don't compare x & y and then later y & x.
  other_ids.select{|x| x > id}.each do |other_id|
    other_words = get_words.call(other_id);
    # & works as set intersection
    overlap     = words & other_words;
    # Don't bother unless they have enough words in common.
    if (overlap.size == words.size || overlap.size > overlap_min_size) then
      # The words that only occur in one of the sets
      misses = (words + other_words) - overlap;
      overlap_tot_freq = overlap.map{|w| inv_freq.call(w)}.reduce(:+) || 0;
      misses_tot_freq  = misses.map{|w|  inv_freq.call(w)}.reduce(:+) || 0;
      score            = (overlap_tot_freq - misses_tot_freq) / (overlap.size + misses.size);

      if $verbose == true then
        puts "words #{words.join(',')}";
        puts "other #{other_words.join(',')}";
        puts "overlap #{overlap.join(',')}";
        puts "misses #{misses.join(',')}";
        puts "score (#{overlap_tot_freq} - #{misses_tot_freq}) / (#{overlap.size} + #{misses.size}) = #{score}";
        puts "---";
      end

      # Arbitrary cutoff. Only output if the score is high enough.
      if score > score_cutoff then
        # Output pair of ids, score and overlapping words.
        hdout.file.puts [id, other_id, score.round(3), overlap.join(',')].join("\t");
        outputted += 1;
      end

      comparisons += 1;
      if comparisons % 10000 == 0 then
        log.d("#{comparisons} record pairs compared, #{outputted} outputted");
      end
    end
  end
end
hdout.close();

log.d("#{comparisons} record pairs compared, #{outputted} outputted");
log.d("Donzo.")