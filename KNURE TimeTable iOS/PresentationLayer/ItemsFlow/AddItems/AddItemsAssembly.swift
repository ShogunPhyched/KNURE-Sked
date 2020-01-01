//
//  AddItemsAssembly.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 01/01/2020.
//  Copyright © 2020 Vladislav Chapaev. All rights reserved.
//

import Swinject

struct AddItemsAssembly: Assembly {

	func configure(_ container: Container) {
		container.register(AddItemsViewController.self) {
			let interactor = $0.resolve(AddItemsInteractor.self)!
			let controller = AddItemsViewController()

			controller.interactor = interactor
			interactor.output = controller

			return controller
		}

		container.register(AddItemsInteractor.self) {
			AddItemsInteractor(saveItemUseCase: $0.resolve(SaveItemUseCase.self)!,
							removeItemUseCase: $0.resolve(RemoveItemUseCase.self)!)
		}
	}
}
