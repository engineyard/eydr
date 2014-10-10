class Chef::Node
  def ssh_username
    self['users'].first['username']
  end

  def ssh_password
    self['users'].first['password']
  end

  def solo?
    %(solo eylocal).include?(self['instance_role'])
  end

  def apps
    Chef::Recipe::EyApplication.all(self['applications'], self)
  end

  def stunneled?
    @stunneled ||= environment.component?('stunneled') && apps.any? {|a| a.https?}
  end

  def instance
    @instance ||= begin
      id = self['engineyard']['this']
      Instance.new(environment.instances.detect {|i| i['id'] == id})
    end
  end

  def environment
    @environment ||= Environment.new(self['engineyard']['environment'])
  end

  class Environment
    RUBY_REGEXP = /^(j?ruby(?!gems)|rubinius|ree)/

    def initialize(hash)
      @hash = hash
    end

    def instances
      @hash['instances']
    end

    def framework_env
      @hash['framework_env']
    end

    def component?(name)
      @hash['components'].any? {|c| c['key'] == name.to_s}
    end

    def component(name)
      @hash['components'].detect {|c| c['key'] == name.to_s}
    end

    def components
      @hash['components'] || Hash.new()  # CC-148 - Chef 0.10.9 fix
    end

    def respond_to?(method)
      @hash.key?(method) || @hash.key?(method.to_s) || super
    end

    def method_missing(method, *args)
      respond_to?(method) ? (@hash[method] || @hash[method.to_s]) : super
    end

    def ruby?
      @hash['components'].any? {|c| c['key'] =~ RUBY_REGEXP }
    end

    def jruby?
      @hash['components'].any? {|c| c['key'] =~ /^jruby/ }
    end

    def rubygems?
      @hash['components'].any? {|c| c['key'] =~ /^rubygems/ }
    end

    def lock_db_version?
      @hash['components'].any? {|c| c['key'] =~ /^lock_db_version/ }
    end

    def app_servers
      instances.select {|i| i['role'] =~ /^app/}
    end

    def app_private_hostnames
      app_servers.map {|i| i['private_hostname']}
    end

    def ruby
      if component = @hash['components'].detect {|c| c['key'] =~ RUBY_REGEXP }
        key = component['key'].to_sym
        r = rubies[key]
        r[:key] = key

        # Rubygems should use the value specified in rubies method if present, otherwise use DNApi value
        unless r.has_key? :rubygems
          r[:rubygems] = rubygems? ? components.find_all {|e| e['key'] == 'rubygems'}.first['version'] : nil
        end
        if key == :ruby_200 and r[:rubygems] == '2.0.0'
          r[:rubygems] = '2.0.3'
        end
        r
      end
    end

    def rubies
      # this is now (once again?) the canonical place to set ruby versions (ie, patch levels).
      # Setting it in the DNA is no longer desired, as it could result in users getting a new patch level
      # without hitting "Upgrade" (because the new patch level would be sent with their DNA on an "Apply")
      base = {:flavor => 'dev-lang/ruby', :module => 'ruby18'}
      {
        :ruby_186   => base.merge({:version => '1.8.6_p420-r2',    :rubygems => '1.4.2'}),
        :ruby_187   => base.merge({:version => '1.8.7_p357'}),
        :ree        => base.merge({:version => '1.8.7.2012.02-r1', :module => 'rubyee',      :flavor => 'dev-lang/ruby-enterprise'}),
        :ruby_192   => base.merge({:version => '1.9.2_p320',       :module => 'ruby19'}),
        :ruby_193   => base.merge({:version => '1.9.3_p547',       :module => 'ruby19'}),
        :ruby_200   => base.merge({:version => '2.0.0_p481',       :module => 'ruby20'}),
        :ruby_212   => base.merge({:version => '2.1.2_p95',        :module => 'ruby21'}),
        :jruby_187  => base.merge({:version => '1.6.7.2',          :module => 'rubyjruby16', :flavor => 'dev-java/jruby'     }),
        :jruby_192  => base.merge({:version => '1.6.7.2',          :module => 'rubyjruby16', :flavor => 'dev-java/jruby'     }),
        :rubinius   => base.merge({:version => '2.0.0_rc2',        :module => 'rubyrbx20-18', :flavor => 'dev-lang/rubinius' }),
        :rubinius19 => base.merge({:version => '2.0.0_rc2',        :module => 'rubyrbx20-19', :flavor => 'dev-lang/rubinius' }),
        :rubinius20 => base.merge({:version => '2.0.0_rc2',        :module => 'rubyrbx20-20', :flavor => 'dev-lang/rubinius' })
      }
    end

    def db_adapter(app_type)
      if @hash['db_stack_name'] == 'mysql' && app_type == 'rack'
        'mysql2'
      else
        stack_name = @hash['db_stack_name'].gsub /[^a-z]+/, ''
        # see https://tickets.engineyard.com/issue/DATA-66 to understand this hax
        stack_name == 'postgres' ? 'postgresql' : stack_name
      end
    end

    def [](name)
      @hash[name]
    end

    def region
      @hash['region']
    end

    def backup_bucket
      @hash['backup_bucket']
    end
  end

  class Instance
    def initialize(hash)
      @hash = hash
    end

    def id
      @hash['id']
    end

    def component?(name)
      @hash['components'].any? {|c| c['key'] == name.to_s}
    end

    def component(name)
      @hash['components'].detect {|c| c['key'] == name.to_s}
    end

    def respond_to?(method)
      @hash.key?(method) || @hash.key?(method.to_s) || super
    end

    def method_missing(method, *args)
      respond_to?(method) ? (@hash[method] || @hash[method.to_s]) : super
    end
  end
end
