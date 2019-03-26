//
//  PromisedCoreDataSource.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 24/03/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import CoreData
import PromiseKit

class PromisedCoreDataSource: CoreDataSource {
	
	let coreDataService: CoreDataService
	
	init(coreDataService: CoreDataService) {
		self.coreDataService = coreDataService
	}
	
	func fetch<T>(_ request: NSFetchRequest<NSFetchRequestResult>) -> Guarantee<[T]> {
		return Guarantee(resolver: { seal in
			
			var result: [T] = []
			let context = self.coreDataService.parentContext
			
			do {
				let fetchResult = try context.fetch(request) as! T
				result.append(fetchResult)
				
			} catch {
				print("\(#file) \(#function) \(error)")
			}
			
			seal(result)
		})
	}
	
	func delete(_ request: NSFetchRequest<NSFetchRequestResult>) -> Promise<Void> {
		return Promise(resolver: { seal in
			let context = self.coreDataService.parentContext
			do {
				let objects: [NSManagedObject] = try context.fetch(request) as! [NSManagedObject]
				objects.forEach { context.delete($0) }
				try context.save()
				seal.fulfill(())
			} catch {
				seal.reject(error)
			}
		})
	}
}
