#!/usr/bin/env ruby

### call RNAfold using ratio constraints

if ARGV.size == 5
	dir, score_tag, constraint_tag, upper_threshold, lower_threshold = ARGV
	dir = dir.gsub(/\/$/, "")
	constraint_tag = constraint_tag.gsub(/^\./, "")
	score_tag = score_tag.gsub(/^\./, "")
else
	puts "USAGE: #{$0} dir score_tag constraint_tag upper_threshold lower_threshold"
	exit -1
end

Dir.glob("#{dir}/*.seq").each { |seqfile|
	id = File.basename(seqfile, ".seq")
	ratio_file = "#{dir}/#{id}.#{constraint_tag}"
	score_file = "#{dir}/#{id}.#{score_tag}" 
	rnafold_file = "#{dir}/#{id}.rnafold"
	puts "generating .svgs for #{id}" 
	
	# run RNAfold
	system("RNAfold --noPS -C < #{ratio_file} > #{rnafold_file}")
	
	# run RNAplot
	system("RNAplot -o svg < #{rnafold_file}")
	system("mv rna.svg #{dir}/#{id}.svg")
	
	# run SAVoR
	system("ruby annotate_svg_plot.rb \"#{dir}/#{id}.svg\" \"#{score_file}\" -a structure_score -s -z -m 10 -e -hmin #{lower_threshold} -hmax #{upper_threshold} -colorscheme blue-red > \"#{dir}/#{id}.annot.svg\"")
	
}

