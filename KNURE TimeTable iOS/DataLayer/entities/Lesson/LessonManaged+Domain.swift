//
//  LessonManaged+Domain.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 08/08/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Foundation

extension LessonManaged: DomainConvertable {
	typealias DomainType = Lesson

	var domainValue: Lesson {
		// TODO: implement
		return Lesson()
	}
}
