//
//  AddItemsViewModel.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 01/01/2020.
//  Copyright © 2020 Vladislav Chapaev. All rights reserved.
//

import RxSwift

struct AddItemsViewModel {
	var items: BehaviorSubject<[Item]>
	var searchingItems: BehaviorSubject<[Item]>
	var selectedType: TimetableItem

	static let cellId = "TimetableAddItem"

	init() {
		items = BehaviorSubject(value: [])
		searchingItems = BehaviorSubject(value: [])
		selectedType = .group
	}
}