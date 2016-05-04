# coding: utf-8
#
# unobtainium-multifind
# https://github.com/jfinkhaeuser/unobtainium-multifind
#
# Copyright (c) 2016 Jens Finkhaeuser and other unobtainium-multifind contributors.
# All rights reserved.
#

require 'unobtainium'

module Unobtainium
  ##
  # MultiFind namespace
  module MultiFind
    ##
    # Driver module implementing multi find functionality.
    module DriverModule

      ##
      # Default options. This hash is also used to detect if any of the Hashes
      # passed to #multifind is an options Hash; it is considered one if it
      # contains any of the keys specified here.
      DEFAULT_OPTIONS = {
        # If true, raises on error instead of returning nil
        raise_on_error: false,
        # If true, returns the error object instead of nil
        return_errors: false,
        # If :all is specified, all results are returned.
        # If :first is specified, the first non-error result is
        #   returned.
        # If :last is specified, the last non-error result is
        #   returned.
        find: :all,
      }.freeze

      class << self
        ##
        # Returns true if the implementation has `#find_element`, false
        # otherwise.
        def matches?(impl)
          return impl.respond_to?(:find_element)
        end
      end # class << self

      ##
      # Current options for multifind
      attr_accessor :multifind_options
      @multifind_options = DEFAULT_OPTIONS

      def multifind(*args)
        # Parse options
        options, selectors = multifind_parse_options(*args)

        # Now find elements
        results = []
        selectors.each do |selector|
          begin
            results << find_element(selector)
          rescue ::Selenium::WebDriver::Error::NoSuchElementError => err
            if options[:raise_on_error]
              raise
            end
            if options[:return_errors]
              results << err
              next
            end
            results << nil
          end
        end

        # Filter results, if necessary
        return multifind_filter_results(options, results)
      end

      alias find multifind

      private

      ##
      # Distinguishes between option hashes and selectors by detecting Hash
      # arguments with keys from DEFAULT_OPTIONS. Those are considered to be
      # options, and merged with any preceding option hashes, where latter
      # occurrences overwrite earlier ones.
      def multifind_parse_options(*args)
        # Sanity
        if @multifind_options.nil?
          @multifind_options = DEFAULT_OPTIONS
        end

        # Distinguish between options and selectors
        options = {}
        selectors = []
        args.each do |arg|
          # Let the underlying API handle all non-Hashes
          if not arg.is_a?(Hash)
            selectors << arg
            next
          end

          # See if it contains any of the keys we care about
          option_keys = DEFAULT_OPTIONS.keys
          diff = option_keys - arg.keys
          if diff != option_keys
            options.merge!(arg)
            next
          end

          selectors << arg
        end
        options = @multifind_options.merge(options)
        options = DEFAULT_OPTIONS.merge(options)

        # Ensure that the 'find' option contains correct
        # values only.
        if not [:all, :first, :last].include?(options[:find])
          raise ArgumentError, ":find option must be one of :all, :first or "\
            ":last, but is: #{options[:find]}"
        end

        return options, selectors
      end

      ##
      # Filters results from multifind; this largely means honouring the
      # :find option.
      def multifind_filter_results(options, results)
        # That was easy!
        if options[:find] == :all
          return results
        end

        # Filtering :first and :last is identical, except we go backwards
        # through the results array for :last.
        if options[:find] == :last
          results.reverse!
        end

        # We now return the first non-nil, non-error result
        results.each do |result|
          if result.nil?
            next
          end
          if result.is_a?(::Selenium::WebDriver::Error::NoSuchElementError)
            next
          end
          return [result]
        end

        # If we're here then we have no results, but want :first
        # or :last. An empty result is appropriate.
        return []
      end
    end # module DriverModule
  end # module MultiFind
end # module Unobtainium

::Unobtainium::Driver.register_module(
    ::Unobtainium::MultiFind::DriverModule,
    __FILE__)