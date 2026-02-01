# frozen_string_literal: true

# ConfigValidator provides validation methods for multi-vagrant configuration
module ConfigValidator
  VALID_PROVIDERS = %w[virtualbox vmware_desktop vmware_fusion lxc].freeze
  VALID_PROVISIONERS = %w[none ansible salt].freeze
  HOSTNAME_REGEX = /\A[a-zA-Z0-9][a-zA-Z0-9\-]*\z/.freeze

  class ValidationError < StandardError; end

  class << self
    def validate_config(config_data)
      errors = []

      settings = config_data['settings'] || {}
      vms = config_data['vms'] || []

      # Validate required settings
      errors << "settings.codebase is required" if empty_value?(settings['codebase'])
      errors << "settings.codedest is required" if empty_value?(settings['codedest'])

      # Validate provider
      provider = settings['provider'] || 'virtualbox'
      unless VALID_PROVIDERS.include?(provider)
        errors << "Invalid provider '#{provider}'. Valid options: #{VALID_PROVIDERS.join(', ')}"
      end

      # Validate provisioner
      provisioner = settings['provisioner'] || 'none'
      unless VALID_PROVISIONERS.include?(provisioner)
        errors << "Invalid provisioner '#{provisioner}'. Valid options: #{VALID_PROVISIONERS.join(', ')}"
      end

      # Validate VMs
      vms.each_with_index do |vm, index|
        errors.concat(validate_vm(vm, index))
      end

      errors
    end

    def validate_vm(vm, index)
      errors = []

      # Name is required
      if vm['name'].nil? || vm['name'].to_s.empty?
        errors << "vms[#{index}]: 'name' is required"
      elsif !valid_hostname?(vm['name'])
        errors << "vms[#{index}]: name '#{vm['name']}' is invalid. Use only alphanumeric characters and hyphens."
      end

      # Validate provider if specified
      if vm['provider'] && !VALID_PROVIDERS.include?(vm['provider'])
        errors << "vms[#{index}]: Invalid provider '#{vm['provider']}'. Valid options: #{VALID_PROVIDERS.join(', ')}"
      end

      # Validate ram is numeric if specified
      if vm['ram'] && !numeric?(vm['ram'])
        errors << "vms[#{index}]: ram must be a number (got '#{vm['ram']}')"
      end

      # Validate cpu is numeric if specified
      if vm['cpu'] && !numeric?(vm['cpu'])
        errors << "vms[#{index}]: cpu must be a number (got '#{vm['cpu']}')"
      end

      errors
    end

    def valid_hostname?(name)
      return false if name.nil?
      name.to_s.match?(HOSTNAME_REGEX)
    end

    def valid_provider?(provider)
      VALID_PROVIDERS.include?(provider)
    end

    def valid_provisioner?(provisioner)
      VALID_PROVISIONERS.include?(provisioner)
    end

    private

    def empty_value?(value)
      value.nil? || value.to_s.empty? || value.is_a?(Hash)
    end

    def numeric?(value)
      value.to_s.match?(/\A\d+\z/)
    end
  end
end
