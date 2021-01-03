
import UIKit

class ViewController: UIViewController {
  /**
   lastPoint stores the last drawn point on the canvas. You’ll need this when your user draws a continuous brush stroke on the canvas.
   color stores the current selected color. It defaults to black.
   brushWidth stores the brush stroke width. It defaults to 10.0.
   opacity stores the brush opacity. It defaults to 1.0.
   swiped indicates if the brush stroke is continuous.
   
   
   
   this app has two image views: mainImageView, which holds the “drawing so far”, and tempImageView, which holds the “line you’re currently drawing”.

   */
  var lastPoint=CGPoint.zero
  var color=UIColor.black
  var brushWidth:CGFloat=10.0
  var opacity:CGFloat=1.0
  var swiped=false
  @IBOutlet weak var mainImageView: UIImageView!
  @IBOutlet weak var tempImageView: UIImageView!
  
  // MARK: - Actions
  
  @IBAction func resetPressed(_ sender: Any) {
    mainImageView.image = nil
  }
  
  @IBAction func sharePressed(_ sender: Any) {
    guard let image = mainImageView.image else {
      return
    }
    
    let activity = UIActivityViewController(activityItems: [image],
                                            applicationActivities: nil)
    present(activity, animated: true)


  }
  
  @IBAction func pencilPressed(_ sender: UIButton) {

    guard let pencil = Pencil(tag: sender.tag) else {
      return
    }
    color = pencil.color

    if pencil == .eraser {
      opacity = 1.0
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch=touches.first else{
      return
    }
    swiped=false
    lastPoint=touch.location(in: view)
  }
  
  //  responsible for drawing a line between two points
  //get the current touch point and then draw a line from lastPoint to currentPoint. You might think that this approach will produce a series of straight lines and the result will look like a set of jagged lines. This will produce straight lines, but the touch events fire so quickly that the lines are short enough and the result will look like a nice smooth curve.
  
  func drawLine(from fromPoint:CGPoint,to toPoint:CGPoint)  {
    UIGraphicsBeginImageContext(view.frame.size)
    guard let context=UIGraphicsGetCurrentContext()else{
      return
    }
    tempImageView.image?.draw(in: view.bounds)
    context.move(to: fromPoint)
     context.addLine(to: toPoint)
     
     context.setLineCap(.round)
     context.setBlendMode(.normal)
     context.setLineWidth(brushWidth)
     context.setStrokeColor(color.cgColor)
     
     context.strokePath()
     
     tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
     tempImageView.alpha = opacity
     UIGraphicsEndImageContext()
  }
  
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }

    swiped = true
    let currentPoint = touch.location(in: view)
    drawLine(from: lastPoint, to: currentPoint)
      
    lastPoint = currentPoint
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if !swiped {
      // draw a single point
      drawLine(from: lastPoint, to: lastPoint)
    }
      
    // Merge tempImageView into mainImageView
    UIGraphicsBeginImageContext(mainImageView.frame.size)
    mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
    tempImageView?.image?.draw(in: view.bounds, blendMode: .normal, alpha: opacity)
    mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
      
    tempImageView.image = nil
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard
      let navController = segue.destination as? UINavigationController,
      let settingsController = navController.topViewController as? SettingsViewController
    else {
        return
    }
    settingsController.delegate = self
    settingsController.brush = brushWidth
    settingsController.opacity = opacity
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: nil)
    settingsController.red = red
    settingsController.green = green
    settingsController.blue = blue
  }
  
  
}


/**
 guard true else {
   print("Condition not met")
 }
 print("Condition met")
 */

extension ViewController: SettingsViewControllerDelegate {
  
  func settingsViewControllerFinished(_ settingsViewController: SettingsViewController) {
    brushWidth = settingsViewController.brush
    opacity = settingsViewController.opacity
    color = UIColor(red: settingsViewController.red,
                    green: settingsViewController.green,
                    blue: settingsViewController.blue,
                    alpha: opacity)
    dismiss(animated: true)
  }
}
