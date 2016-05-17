//
//  ViewController.swift
//  BookFinder
//
//  Created by Mando on 4/25/16.
//  Copyright © 2016 Armando Muñoz Hernández. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var isbnTextField: UITextField!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var bookContainerView: UIView!
	var bookViewController: BookViewController?
	
	let book: Book? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		isbnTextField.delegate = self
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if (textField == isbnTextField && textField.text?.characters.count > 0) {
			activityIndicator.startAnimating()
			textField.resignFirstResponder()
			return true
		}
		return false
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		if (textField == isbnTextField) {
			loadBook(isbnTextField.text!)
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "bookViewSegueId" {
			self.bookViewController = (segue.destinationViewController as! BookViewController)
		}
	}
	
	private func showAlert(let title title: String?, let message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: "Cerrar", style: UIAlertActionStyle.Default, handler: nil))
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	private func loadBook(let isbn: String) {
		let urlString = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbn)"
		let url: NSURL? = NSURL(string: urlString)
		let request: NSURLRequest = NSURLRequest(URL: url!)
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		let session = NSURLSession(configuration: config)
		let task = session.dataTaskWithRequest(request, completionHandler: self.loadBookCompletionHandler)
		task.resume()
	}
	
	private func loadBookCompletionHandler(data: NSData?, response: NSURLResponse?, error: NSError?) {
		dispatch_async(dispatch_get_main_queue(), {
			if error == nil {
				do {
					let data = String(data: data!, encoding: NSUTF8StringEncoding)
					let book: Book = try self.getBook(fromJSONString: data!)
					self.bookViewController!.setBookInformation(book)
					self.bookContainerView.hidden = false
				} catch BookFinderError.BookDoesNotExist {
					self.showAlert(title: nil, message: "El libro solicitado no existe.")
					self.bookContainerView.hidden = true
				} catch _ {
					self.showAlert(title: self.isbnTextField.text!, message: "Ocurrió un error inesperado al tratar de obtener la información del libro con el ISBN \(self.isbnTextField.text!)")
				}
			} else {
				self.showAlert(title: "Error de red", message: "Ocurrió un error al tratar de acceder a la información del libro con el ISBN \(self.isbnTextField.text!). Revisa tu conexión a Internet")
				self.bookContainerView.hidden = true
			}
			self.activityIndicator.stopAnimating()
		})
	}
	
	private func getBook(let fromJSONString jsonString: String) throws -> Book {
		let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
		let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
		var book: Book = Book()
		let bookObject = json["ISBN:" + isbnTextField.text!] as? [String: AnyObject]
		guard bookObject != nil else {
			throw BookFinderError.BookDoesNotExist
		}
		book.title = bookObject!["title"] as? String
		if let authorsArray = bookObject!["authors"] as? [[String: AnyObject]] {
			var authors: [String] = [String]()
			for authorObject in authorsArray {
				authors.append(authorObject["name"] as! String)
			}
			book.authors = authors
		}
		if let coverObject = bookObject!["cover"] as? [String: AnyObject] {
			book.cover = coverObject["large"] as? String
		}
		return book
	}
}

struct Book {
	
	var title: String?
	var authors: [String]?
	var cover: String?
}

enum BookFinderError: ErrorType {
	case InfoDownloadError(code: Int)
	case BookDoesNotExist
}
