//
// WebsiteController+Category.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Leaf
import Vapor

extension WebsiteController {
    func allCategoriesHandler(_ req: Request) -> EventLoopFuture<View> {
        Category.query(on: req.db)
            .all()
            .flatMap { categories in
                let context = AllCategoriesContext(categories: categories)
                return req.view.render("allCategories", context)
            }
    }

    func categoryHandler(_ req: Request) -> EventLoopFuture<View> {
        Category.find(req.parameters.get("categoryId"),
                      on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                category.$acronyms.get(on: req.db)
                    .flatMap { acronyms in
                        let context = CategoryContext(title: category.name, category: category, acronyms: acronyms)
                        return req.view.render("category", context)
                    }
            }
    }
}

// MARK: - AllCategoriesContext

struct AllCategoriesContext: Encodable {
    let title = "All Categories"
    let categories: [Category]
}

// MARK: - CategoryContext

struct CategoryContext: Encodable {
    let title: String
    let category: Category
    let acronyms: [Acronym]
}
