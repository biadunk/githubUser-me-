//
//  ContentView.swift
//  githubUser(me)
//
//  Created by Kacper Biaduń on 11/07/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .frame(width: 128, height: 128)
            }
                
            Text(user?.login ?? "default username")
                .font(.system(size: 40))
                .bold()
            
            Text(user?.bio ?? "default bio")
                .font(.system(size: 15))
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHError.invalidURL {
                print("Invalid URL")
            } catch GHError.invalidResponse {
                print("Invalid response")
            } catch GHError.invalidData {
                print("Invalid data")
            } catch {
                print("default")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endPoint = "https://api.github.com/users/biadunk"
        guard let url = URL(string: endPoint) else {
            throw GHError.invalidURL
        }
                
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        }
        catch {
            throw GHError.invalidData
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct GitHubUser: Codable {
    var login: String
    var avatarUrl: String
    var bio: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
