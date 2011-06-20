# encoding: utf-8

usage       'debug'
summary     'show debug information for this site'
description <<-EOS
Show information about all items, item representations and layouts in the
current site.
EOS

run do |opts, args|
  Nanoc3::CLI::Commands::Debug.call(opts, args)
end

module Nanoc3::CLI::Commands

  class Debug < ::Nanoc3::CLI::Command

    def run(options, arguments)
      # Make sure we are in a nanoc site directory
      print "Loading site data... "
      base.require_site
      puts "done"
      puts

      # Get data
      items   = base.site.items
      reps    = items.map { |i| i.reps }.flatten
      layouts = base.site.layouts

      # Get dependency tracker
      compiler = base.site.compiler
      compiler.load
      dependency_tracker = compiler.dependency_tracker

      # Print item dependencies
      puts '=== Item dependencies ======================================================='
      puts
      items.sort_by { |i| i.identifier }.each do |item|
        puts "item #{item.identifier} depends on:"
        predecessors = dependency_tracker.objects_causing_outdatedness_of(item).sort_by { |i| i.identifier }
        predecessors.each do |pred|
          puts "  [ #{format '%6s', pred.type} ] #{pred.identifier}"
        end
        puts "  (nothing)" if predecessors.empty?
        puts
      end

      # Print representation paths
      puts '=== Representation paths ===================================================='
      puts
      items.sort_by { |i| i.identifier }.each do |item|
        item.reps.sort_by { |r| r.name.to_s }.each do |rep|
          puts "item #{item.identifier}, rep #{rep.name}:"
          if rep.raw_paths.empty?
            puts "  (not written)"
          end
          length = rep.raw_paths.keys.map { |s| s.to_s.length }.max
          rep.raw_paths.each do |snapshot_name, raw_path|
            puts "  [ %-#{length}s ] %s" % [ snapshot_name, raw_path ]
          end
        end
        puts
      end

      # Print representation outdatedness
      puts '=== Representation outdatedness ============================================='
      puts
      items.sort_by { |i| i.identifier }.each do |item|
        item.reps.sort_by { |r| r.name.to_s }.each do |rep|
          puts "item #{item.identifier}, rep #{rep.name}:"
          outdatedness_reason = compiler.outdatedness_checker.outdatedness_reason_for(rep)
          if outdatedness_reason
            puts "  is outdated: #{outdatedness_reason.message}"
          else
            puts "  is not outdated"
          end
        end
        puts
      end

      # Print layouts
      puts '=== Layouts'
      puts
      layouts.each do |layout|
        puts "layout #{layout.identifier}:"
        outdatedness_reason = compiler.outdatedness_checker.outdatedness_reason_for(layout)
        if outdatedness_reason
          puts "  is outdated: #{outdatedness_reason.message}"
        else
          puts "  is not outdated"
        end
        puts
      end
    end

  end

end
