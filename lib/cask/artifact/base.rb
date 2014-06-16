class Cask::Artifact::Base

  def self.artifact_name
    @artifact_name ||= self.name.sub(%r{^.*:}, '').gsub(%r{(.)([A-Z])}, '\1_\2').downcase
  end

  def self.artifact_english_name
    @artifact_english_name ||= self.name.sub(%r{^.*:}, '').gsub(%r{(.)([A-Z])}, '\1 \2')
  end

  def self.artifact_english_article
    @artifact_english_article ||= self.artifact_english_name.match(%r{^[aeiou]}i) ? 'an' : 'a'
  end

  def self.artifact_dsl_key
    @artifact_dsl_key ||= self.artifact_name.to_sym
  end

  def self.artifact_dirmethod
    @artifact_dirmethod ||= "#{self.artifact_name}dir".to_sym
  end

  def self.me?(cask)
     cask.artifacts[self.artifact_dsl_key].any?
  end

  # todo: this sort of logic would make more sense in dsl.rb, or a
  # constructor called from dsl.rb, so long as that isn't slow.
  def self.read_script_arguments(arguments, stanza, key=nil)
    # todo: when stanza names are harmonized with class names,
    # stanza may not be needed as an explicit argument
    description = stanza.to_s
    if key
      arguments = arguments[key]
      description.concat(" #{key.inspect}")
    end

    # backwards-compatible string value
    if arguments.kind_of?(String)
      arguments = { :executable => arguments }
    end

    # key sanity
    permitted_keys = [:args, :input, :executable, :must_succeed]
    unknown_keys = arguments.keys - permitted_keys
    unless unknown_keys.empty?
      opoo "Unknown arguments to #{description} -- :#{unknown_keys.join(", :")} (ignored). Running `brew update; brew upgrade brew-cask` will likely fix it.'"
    end
    arguments.reject! {|k,v| ! permitted_keys.include?(k)}

    # extract executable
    if arguments.key?(:executable)
      executable = arguments.delete(:executable)
    else
      executable = nil
    end

    unless arguments.key?(:must_succeed)
      arguments[:must_succeed] = true
    end

    arguments.merge!(:sudo => true, :print => true)
    return executable, arguments
  end

  def summary
    {}
  end

  def initialize(cask, command=Cask::SystemCommand)
    @cask = cask
    @command = command
  end
end
