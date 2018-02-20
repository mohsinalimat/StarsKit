// The MIT License (MIT)
//
// Copyright (c) 2018 Smart&Soft
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation


/// Step of the rating process
///
/// - rating: User has to choose a rating
/// - feedback: User has to choose giving a feedback because of disliking
/// - storeReview: User has the choice of giving an AppStore review
public enum RatingStep {
  case rating(context: StarsKitContext)
  case feedback(context: StarsKitContext)
  case storeReview(context: StarsKitContext)
}

/// Coordinate rating workflow
final class StarsRatingCoordinator {
  
  private var graphicContext: StarsKitGraphicContext
  private var context: StarsKitContext
  
  private var step: RatingStep
  
  private weak var starsPopViewController: StarsPopViewController?
  private var rateViewController: StarsRateViewController?
  private var storeViewController: StoreViewController?
  private var feedbackViewController: FeedbackViewController?
  
  // MARK: Initializers
  init(starsPopViewController: StarsPopViewController, context: StarsKitContext, graphicContext: StarsKitGraphicContext) {
    self.starsPopViewController = starsPopViewController
    self.graphicContext = graphicContext
    self.context = context
    self.step = RatingStep.rating(context: context)
  }
  
  // MARK: Workflow
  func start() {
    self.rateViewController = StarsRateViewController(graphicContext: self.graphicContext, coordinator: self)
    if let starsPopViewController = self.starsPopViewController, let starsRateController = self.rateViewController {
      starsPopViewController.ex.addChildViewController(starsRateController,
                                                       in: starsPopViewController.ibContainerView)
    }
  }
  
  func endRating(to rate: Double) {
    let rate = Int(rate)
    StarsKit.shared.delegate?.didUpdateRating(from: self.context, to: rate)
    if rate < StarsKit.shared.configuration.positiveStarsLimit {
      self.makeFeedback()
    } else {
      self.makeStoreReview()
    }
  }
  
  private func makeFeedback() {
    self.step = .feedback(context: self.context)
    if let starsPopViewController = self.starsPopViewController {
      let feebackController = FeedbackViewController(graphicContext: self.graphicContext, coordinator: self)
      self.feedbackViewController = feebackController
      starsPopViewController.ex.switchChilds(from: self.rateViewController,
                                             to: feebackController,
                                             in: starsPopViewController.ibContainerView)
    }
  }
  
  private func makeStoreReview() {
    self.step = .storeReview(context: self.context)
    if let starsPopViewController = self.starsPopViewController {
      let storeViewController = StoreViewController(graphicContext: self.graphicContext, coordinator: self)
      self.storeViewController = storeViewController
      starsPopViewController.ex.switchChilds(from: self.rateViewController,
                                             to: storeViewController,
                                             in: starsPopViewController.ibContainerView)
    }
  }
  
  // MARK: Step ending events
  func didChooseFeedback() {
    StarsKit.shared.delegate?.didChooseAction(at: self.step, from: self.context)
    self.starsPopViewController?.dismiss(animated: true, completion: nil)
  }
  
  func didChooseStoreReview() {
    StarsKit.shared.delegate?.didChooseAction(at: self.step, from: self.context)
    self.starsPopViewController?.dismiss(animated: true, completion: nil)
  }
  
  func later() {
    StarsKit.shared.delegate?.didChooseLater(at: self.step, from: self.context)
    self.starsPopViewController?.dismiss(animated: true, completion: nil)
  }
  
}