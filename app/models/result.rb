class Result < ActiveRecord::Base
  belongs_to :solution
  belongs_to :test, :class_name =>'ProblemTest', :foreign_key=>'test_id'
  named_scope :correct, :conditions => { :matched => true }
  named_scope :incorrect, :conditions => { :matched => false }
  named_scope :real, :conditions => { :hidden => true }
  

  def after_create    
    lines = IO.readlines(self.solution.usage_path)
    self.status = lines[0]
    self.time = lines[-1].sub('cpu usage: ','').sub(' miliseconds','')
    self.memory = lines[-2].sub('memory usage: ','').sub(' kbytes','')
    self.diff = self.test.diff(self.solution.output_path)
    self.matched = self.diff.empty?
    self.output = IO.readlines(self.solution.output_path).join
    self.hidden = self.test.hidden
    save!
  end

  def failed?
    not correct?
  end

  def normal?
    self.status && self.status.strip.eql?('OK')
  end

  def correct?
    normal? and matched
  end

end
