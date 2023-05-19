# rubocop:disable Naming/MethodName

class MyAppObserver < Sketchup::AppObserver
  def onQuit(model)
    Vectorize.app.log "onQuit: #{model.title.inspect}"
    Vectorize.app.logger.close
  end

  def onOpenModel(model)
    Vectorize.app.log "onOpenModel: #{model.title.inspect}"
  end

  def expectsStartupModelNotifications
    true
  end
end

# Attach the observer
Sketchup.add_observer(MyAppObserver.new)
