//
//  BookViewController.swift
//  BookFinder
//
//  Created by Mando on 4/25/16.
//  Copyright © 2016 Armando Muñoz Hernández. All rights reserved.
//

import UIKit

class BookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var book: Book?
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorsTable: UITableView!
	@IBOutlet weak var authorsTableHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var coverImage: UIImageView!
	
	override func viewDidLoad() {
		authorsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "simpleCell")
	}
	
	func setBookInformation(book: Book) {
		self.book = book
		titleLabel.text = book.title
		authorsTable.reloadData()
		authorsTable.sizeToFit()
		authorsTableHeightConstraint.constant = authorsTable.rowHeight * CGFloat(book.authors != nil ? book.authors!.count : 1)
		if (book.cover != nil) {
			let data = NSData(contentsOfURL: NSURL(string: book.cover!)!)
			coverImage.image = UIImage(data: data!)
		} else {
			coverImage.image = UIImage(named: "NoCover")
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (book != nil) {
			if (book?.authors != nil) {
				return (book?.authors?.count)!
			} else {
				return 1
			}
		}
		return 0
	}
	// 220 225 197  47 107 165
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: UITableViewCell =  authorsTable.dequeueReusableCellWithIdentifier("simpleCell")!
		cell.backgroundColor = UIColor.clearColor()
		cell.textLabel?.font = UIFont.italicSystemFontOfSize(15)
		if (book?.authors != nil) {
			cell.textLabel?.textColor = UIColor.darkGrayColor()
			cell.textLabel?.text = "• \((book?.authors![indexPath.row])!)"
		} else {
			cell.textLabel?.textColor = UIColor.lightGrayColor()
			cell.textLabel?.text = "[Información del autor no está disponible]"
		}
		return cell
	}
}
