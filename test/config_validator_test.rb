# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/config_validator'

class ConfigValidatorTest < Minitest::Test
  # ===================
  # Provider validation
  # ===================

  def test_valid_providers
    %w[virtualbox vmware_desktop vmware_fusion lxc].each do |provider|
      assert ConfigValidator.valid_provider?(provider), "#{provider} should be valid"
    end
  end

  def test_invalid_provider
    refute ConfigValidator.valid_provider?('docker')
    refute ConfigValidator.valid_provider?('aws')
    refute ConfigValidator.valid_provider?('')
    refute ConfigValidator.valid_provider?(nil)
  end

  # ======================
  # Provisioner validation
  # ======================

  def test_valid_provisioners
    %w[none ansible salt].each do |provisioner|
      assert ConfigValidator.valid_provisioner?(provisioner), "#{provisioner} should be valid"
    end
  end

  def test_invalid_provisioner
    refute ConfigValidator.valid_provisioner?('puppet')
    refute ConfigValidator.valid_provisioner?('chef')
    refute ConfigValidator.valid_provisioner?('')
    refute ConfigValidator.valid_provisioner?(nil)
  end

  # ===================
  # Hostname validation
  # ===================

  def test_valid_hostnames
    valid_names = %w[web01 db-server my-app-01 a 123 test123]
    valid_names.each do |name|
      assert ConfigValidator.valid_hostname?(name), "'#{name}' should be a valid hostname"
    end
  end

  def test_invalid_hostnames
    invalid_names = ['-invalid', 'has_underscore', 'has.dot', 'has space', '', nil]
    invalid_names.each do |name|
      refute ConfigValidator.valid_hostname?(name), "'#{name}' should be an invalid hostname"
    end
  end

  # ==========================
  # Full config validation
  # ==========================

  def test_valid_minimal_config
    config = {
      'settings' => {
        'codebase' => '~/code',
        'codedest' => '/srv/code'
      },
      'vms' => [
        { 'name' => 'web01' }
      ]
    }
    errors = ConfigValidator.validate_config(config)
    assert_empty errors, "Expected no errors, got: #{errors}"
  end

  def test_valid_full_config
    config = {
      'settings' => {
        'codebase' => '~/code',
        'codedest' => '/srv/code',
        'provider' => 'vmware_desktop',
        'provisioner' => 'ansible',
        'domain' => 'test.local'
      },
      'master' => {
        'ram' => 2048,
        'cpu' => 2
      },
      'vms' => [
        { 'name' => 'web01', 'ram' => 1024, 'cpu' => 2, 'provider' => 'virtualbox' },
        { 'name' => 'db01', 'ram' => 4096 }
      ]
    }
    errors = ConfigValidator.validate_config(config)
    assert_empty errors, "Expected no errors, got: #{errors}"
  end

  def test_missing_codebase
    config = {
      'settings' => {
        'codedest' => '/srv/code'
      },
      'vms' => []
    }
    errors = ConfigValidator.validate_config(config)
    assert_includes errors, 'settings.codebase is required'
  end

  def test_missing_codedest
    config = {
      'settings' => {
        'codebase' => '~/code'
      },
      'vms' => []
    }
    errors = ConfigValidator.validate_config(config)
    assert_includes errors, 'settings.codedest is required'
  end

  def test_empty_codebase
    config = {
      'settings' => {
        'codebase' => '',
        'codedest' => '/srv/code'
      },
      'vms' => []
    }
    errors = ConfigValidator.validate_config(config)
    assert_includes errors, 'settings.codebase is required'
  end

  def test_invalid_provider_in_settings
    config = {
      'settings' => {
        'codebase' => '~/code',
        'codedest' => '/srv/code',
        'provider' => 'docker'
      },
      'vms' => []
    }
    errors = ConfigValidator.validate_config(config)
    assert errors.any? { |e| e.include?("Invalid provider 'docker'") }
  end

  def test_invalid_provisioner_in_settings
    config = {
      'settings' => {
        'codebase' => '~/code',
        'codedest' => '/srv/code',
        'provisioner' => 'puppet'
      },
      'vms' => []
    }
    errors = ConfigValidator.validate_config(config)
    assert errors.any? { |e| e.include?("Invalid provisioner 'puppet'") }
  end

  # ==============
  # VM validation
  # ==============

  def test_vm_missing_name
    config = {
      'settings' => {
        'codebase' => '~/code',
        'codedest' => '/srv/code'
      },
      'vms' => [
        { 'ram' => 1024 }
      ]
    }
    errors = ConfigValidator.validate_config(config)
    assert errors.any? { |e| e.include?("'name' is required") }
  end

  def test_vm_invalid_name
    config = {
      'settings' => {
        'codebase' => '~/code',
        'codedest' => '/srv/code'
      },
      'vms' => [
        { 'name' => '-invalid' }
      ]
    }
    errors = ConfigValidator.validate_config(config)
    assert errors.any? { |e| e.include?('is invalid') }
  end

  def test_vm_invalid_provider
    config = {
      'settings' => {
        'codebase' => '~/code',
        'codedest' => '/srv/code'
      },
      'vms' => [
        { 'name' => 'web01', 'provider' => 'invalid' }
      ]
    }
    errors = ConfigValidator.validate_config(config)
    assert errors.any? { |e| e.include?("Invalid provider 'invalid'") }
  end

  def test_vm_non_numeric_ram
    config = {
      'settings' => {
        'codebase' => '~/code',
        'codedest' => '/srv/code'
      },
      'vms' => [
        { 'name' => 'web01', 'ram' => 'lots' }
      ]
    }
    errors = ConfigValidator.validate_config(config)
    assert errors.any? { |e| e.include?('ram must be a number') }
  end

  def test_vm_non_numeric_cpu
    config = {
      'settings' => {
        'codebase' => '~/code',
        'codedest' => '/srv/code'
      },
      'vms' => [
        { 'name' => 'web01', 'cpu' => 'many' }
      ]
    }
    errors = ConfigValidator.validate_config(config)
    assert errors.any? { |e| e.include?('cpu must be a number') }
  end

  def test_vm_numeric_ram_as_string
    config = {
      'settings' => {
        'codebase' => '~/code',
        'codedest' => '/srv/code'
      },
      'vms' => [
        { 'name' => 'web01', 'ram' => '2048' }
      ]
    }
    errors = ConfigValidator.validate_config(config)
    assert_empty errors, "Numeric string for ram should be valid"
  end

  def test_multiple_errors
    config = {
      'settings' => {},
      'vms' => [
        { 'name' => '-bad', 'provider' => 'invalid', 'ram' => 'nope' }
      ]
    }
    errors = ConfigValidator.validate_config(config)
    assert errors.length >= 4, "Expected at least 4 errors, got #{errors.length}: #{errors}"
  end
end
