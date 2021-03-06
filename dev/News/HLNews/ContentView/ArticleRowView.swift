//
//  ArticleRowView.swift
//  HLNews
//
//  Created by Matthew Homer on 3/23/21.
//

import SwiftUI

struct ArticleRowView: View {
    var article: Article
    
    var body: some View {
        NavigationLink(destination: ArticleDetailView(urlString: article.url)) {
            HStack(alignment: .top, spacing: 1) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(article.title)
                        .padding(10)
                    
                if article.author != nil && article.author!.count > 0 {
                    Text("Author: " + article.author!)
                        .lineLimit(2)
                        .padding(10)
                }
            }

            Spacer()
            
            if article.urlToImage != nil {
                AsyncImage(url: URL(string: article.urlToImage!)!,
                    placeholder: { Text("Loading ...") },
                    image: { Image(uiImage: $0)
                    .resizable()
                })
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
               //     .frame(width: 200, height: 200, alignment: .center)
                }
            }
        }
    }
}

struct ArticleRowView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleRowView(article: Article.generateTestData())
    }
}
