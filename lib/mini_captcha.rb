require 'RMagick'
require 'digest'

# The spam protection module. Provides the MiniCaptchaClass, ControllerHelpers, ViewHelpers
# and defines a couple of configuration constants that allow configuration of the code.
# These constants can be overridden in the environment. (define them before
# requiring the library!)
#
module MiniCaptcha
  VERSION = '0.0.1'

  # <tt>@@image_format</tt> - a valid file extension, eg. gif,jpg,png
  mattr_accessor :image_format
  @@image_format = "png"

  # <tt>image_dir</tt> - the location where the generated images are put
  mattr_accessor :image_dir
  @@image_dir = "tmp"

  # <tt>salt</tt> - salt used in the encryption
  mattr_accessor :salt
  @@salt = "D3fAuLt5aLt"

  # <tt>token_length</tt> - the generated token's length
  mattr_accessor :token_length
  @@token_length = 5

  # <tt>token_charset</tt> - a string containing all the possible characters the token can contain
  mattr_accessor :token_charset
  @@token_charset = "23456789abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ" # Omit 0,O,o,I,1,l

  # <tt>image_distort</tt> - a string containing the space separated list of distortion methods
  # to be applied (in order of execution)
  # usable methods are the Magick::Image class methods: see RMagick documentation
  # http://www.simplesystems.org/RMagick/doc/optequiv.html
    # parameters for methods can be passed as long as no spaces are being used in the parameter list
  mattr_accessor :image_distort
  @@image_distort = "charcoal wave(20,160)"

  # <tt>text_properties</tt> - a string containing style for the font and position for the annotation
  mattr_accessor :text_properties
  @@text_properties = "self.font_family = 'arial'; self.gravity = Magick::CenterGravity; self.pointsize = 48; self.stroke = 'transparent'; self.fill = 'black'; self.font_weight = Magick::BoldWeight"

  # <tt>MiniCaptcha::MiniCaptchaClass</tt>
  # read only attributes:
  # <tt>image</tt> - path to the generated token image file
  # <tt>hash</tt> - hash corresponding to the generated token
  # How to use:
  # 1) create a new MiniCaptcha instance
  # 2) call the generate method
  # 3) embed the MiniCaptcha::hash and the image (use MiniCaptcha::get_controlimage(hash) to send the file)
  # 4) request the user for the token (and hash hidden)
  # 5) check the user's response by using MiniCaptcha::check(hashin,token)
  class MiniCaptchaClass
    attr_reader :image, :hash

    # generates a new token
    # call this method each time an MiniCaptcha-challenge should be generated
    #
    # once done, the user can be served with the image and hash
    # and should be requested to send back the hash and the token that
    # was printed on the image
    def generate
      # clean up first, perhaps the MiniCaptcha is being reused
      cleanup
      # generate new token, image and hash
      token = generate_token
      @image = generate_image(token)
      @hash = generate_hash(token)
    end

    # checks a token against a hash
    # if they match, true is returned, false otherwise
    def check(hashin, token)
      challenge = generate_hash(token)
      @hash = hashin
      @image = Rails.root.join(MiniCaptcha.image_dir, "#{@hash}.#{MiniCaptcha.image_format}")
      # get rid of the hash file (if exists)
      cleanup
      challenge == @hash
    end

    protected

    # deletes the image if exists
    def cleanup
      if !@image.nil? && File.exists?(@image) then
        File.delete(@image)
      end
    end

    # generates and returns a new token
    def generate_token
      token = ""
      for i in 1..MiniCaptcha.token_length do
        token += "#{MiniCaptcha.token_charset[rand(MiniCaptcha.token_charset.length),1]}"
      end
      token
    end

    # uses imagemagick to print a token into an image and distort the image
    # parameters:
    # <tt>token</tt> - string containing the text to be printed
    def generate_image(token)
      # use imagemagick to create image from the token text
      imagepath = Rails.root.join(MiniCaptcha.image_dir, "#{generate_hash(token)}.#{MiniCaptcha.image_format}")
      tokenimage = Magick::Image.new(token.length*48/1.5,50)
      tokentext = Magick::Draw.new

      # print the token text
      tokentext.annotate(tokenimage, 0, 0, 0, 0, token) { eval( MiniCaptcha.text_properties ) }

      # distort the text to make it unreadable for OCR software;
      MiniCaptcha.image_distort.split(" ").each { |transform|
          eval("tokenimage = tokenimage.#{transform}")
      }

      tokenimage.write(imagepath)
      # return path to image
      imagepath
    end

    # generates a salted MD5 hash of a given token
    # parameters:
    # <tt>token</tt> - string containing the text to be hashed
    def generate_hash(token)
      hashvalue = Digest::MD5.hexdigest("*#{MiniCaptcha.salt}__#{token}*")
    end
  end

  # MiniCaptcha::ViewHelpers
  module ViewHelpers #:nodoc
    def show_mini_captcha(options={})
      mci = MiniCaptcha::MiniCaptchaClass::new()
      mci.generate
      options[:hash] = mci.hash
      options[:object] = "mini_captcha"
      @mini_captcha_displays =
        {:image => "<img src='/mini_captcha/show_image?hash=#{mci.hash}' alt='mini_captcha.#{MiniCaptcha.image_format}' />",
         :label => options[:label] || "Are you human? (enter text from image)",
         :token => text_field(options[:object], :token, :value => '' ),
         :hash => hidden_field(options[:object], :hash, {:value => options[:hash]}) }
      render :partial => 'mini_captcha/mini_captcha'
    end
  end
  # MiniCaptcha::ViewHelpers


  # MiniCaptcha::ControllerHelpers
  module ControllerHelpers #:nodoc
    # validates captcha and activerecord
    def mini_captcha_valid?(arec = nil)
      result = (!arec.nil? ? arec.valid? : true) && mini_captcha_captcha_valid?
      arec.errors.add_to_base("You failed the captcha challenge.") unless arec.nil? || mini_captcha_captcha_valid?
      result
    end

    # validates captcha challenge (params[:mini_captcha] must exist in the context)
    def mini_captcha_captcha_valid?
      return true if Rails.env.test?
      if params[:mini_captcha]
        mci = MiniCaptcha::MiniCaptchaClass::new()
        result =  mci.check(params[:mini_captcha][:hash], params[:mini_captcha][:token])  # verify the spam-control token
        return result
      else
        return false
      end
    end

    # returns the binary contents of a MiniCaptcha generated image and deletes the image file in paralel
    # to ensure one challenge is only displayed once
    # parameters:
    # <tt>hashin</tt> - pass the original hash to the function so it will find the image based on it
    # returns:
    # buffer with the binary content - use send_data() to deliver it to the user
    def mini_captcha_image(hashin)
      buffer = []
      if !hashin.nil? && !hashin.blank? then
        imagepath = Rails.root.join(MiniCaptcha.image_dir, "#{hashin}.#{MiniCaptcha.image_format}")
        if File.exist?(imagepath) then
          File.open(imagepath,"rb") { |f|
            buffer = f.read(File.size(imagepath))
          }
          File.delete(imagepath)
        end
      end
      buffer
    end
  end
  # MiniCaptcha::ControllerHelpers
end
# Mini Captcha Module

# MiniCaptchaController
# the controller that will take care of serving mini captcha images
class MiniCaptchaController < ActionController::Base
  include MiniCaptcha::ControllerHelpers

  def show_image
    send_data(mini_captcha_image(request.parameters[:hash]), :disposition => 'inline', :filename => "mini_captcha.#{MiniCaptcha.image_format}", :type => "image/#{MiniCaptcha.image_format}")
  end

end

# include view helpers in your actions
ActionView::Base.module_eval do
  include MiniCaptcha::ViewHelpers
end
