module Watir
  
  # This class is the means of accessing an image on a page.
  # Normally a user would not need to create this object as it is returned by the Watir::Container#image method
  #
  # many of the methods available to this object are inherited from the Element class
  #
  class Image < Element
    attr_ole :alt
    attr_ole :src
    attr_ole :file_created_date, :fileCreatedDate

    # this method produces the properties for an image as an array
    def image_string_creator
      n = []
      n <<   "src:".ljust(TO_S_SIZE) + self.src.to_s
      n <<   "file date:".ljust(TO_S_SIZE) + self.fileCreatedDate.to_s
      n <<   "file size:".ljust(TO_S_SIZE) + self.fileSize.to_s
      n <<   "width:".ljust(TO_S_SIZE) + self.width.to_s
      n <<   "height:".ljust(TO_S_SIZE) + self.height.to_s
      n <<   "alt:".ljust(TO_S_SIZE) + self.alt.to_s
      return n
    end
    private :image_string_creator
    
    # returns a string representation of the object
    def to_s
      assert_exists
      r = string_creator
      r += image_string_creator
      return r.join("\n")
    end
    
    # this method returns the filesize of the image, as an int
    def file_size
      assert_exists
      @o.invoke("fileSize").to_i
    end
    
    # returns the width in pixels of the image, as an int
    def width
      assert_exists
      @o.invoke("width").to_i
    end
    
    # returns the height in pixels of the image, as an int
    def height
      assert_exists
      @o.invoke("height").to_i
    end
    
    # This method attempts to find out if the image was actually loaded by the web browser.
    # If the image was not loaded, the browser is unable to determine some of the properties.
    # We look for these missing properties to see if the image is really there or not.
    # If the Disk cache is full (tools menu -> Internet options -> Temporary Internet Files), it may produce incorrect responses.
    def loaded?
      assert_exists
      !file_created_date.empty? && file_size != -1
    end
    
    # this method highlights the image (in fact it adds or removes a border around the image)
    #  * set_or_clear   - symbol - :set to set the border, :clear to remove it
    def highlight(set_or_clear)
      if set_or_clear == :set
        begin
          @original_border = @o.border
          @o.border = 1
        rescue
          @original_border = nil
        end
      else
        begin
          @o.border = @original_border
          @original_border = nil
        rescue
          # we could be here for a number of reasons...
        ensure
          @original_border = nil
        end
      end
    end
    private :highlight
    
    # This method saves the image to the file path that is given.  The
    # path must be in windows format (c:\\dirname\\somename.gif).  This method
    # will not overwrite a previously existing image.  If an image already
    # exists at the given path then a dialog will be displayed prompting
    # for overwrite.
    # path - directory path and file name of where image should be saved
    def save(path)
      @container.goto(src)
      begin
        fill_save_image_dialog(path)
        @container.document.execCommand("SaveAs")
      ensure
        @container.back
      end
    end
    
    def fill_save_image_dialog(path)
      command = "require 'rubygems';require 'rautomation';" <<
                "window=::RAutomation::Window.new(:title => 'Save Picture');" <<
                "window.text_field(:class => 'Edit', :index => 0).set('#{path.gsub(File::SEPARATOR, File::ALT_SEPARATOR)}');" <<
                "window.button(:value => '&Save').click"
      IO.popen("ruby -e \"#{command}\"")
    end
    private :fill_save_image_dialog

  end
  
end
