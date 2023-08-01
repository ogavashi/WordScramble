//
//  ContentView.swift
//  WordScramble
//
//  Created by Oleg Gavashi on 01.08.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var newWord: String = ""
    @State private var usedWords: [String] = [String]()
    @State private var rootWord: String = ""
    
    @State private var userScore: Int = 0
    
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    func addNewWord() {
        let newWord = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard newWord.count > 0 else { return }
        
        guard isOriginal(word: newWord) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: newWord) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isValid(word: newWord) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isBad(word: newWord) else {
            wordError(title: "Word can't be added", message: "You can't just enter key word or any short words")
            return
        }
        
        withAnimation {
            usedWords.insert(newWord, at: 0)
        }
        
        userScore += newWord.count
        
        self.newWord = ""
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        word.allSatisfy { letter in
            rootWord.contains(letter)
        }
    }
    
    func isValid(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isBad(word: String) -> Bool {
        word != rootWord && word.count > 2
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showError = true
        newWord  = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func restartGame() {
        newWord = ""
        usedWords = []
        userScore = 0
        startGame()
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Your current score: \(userScore)") {
                    TextField("Enter your word:", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                .onSubmit(addNewWord)
                Section {
                    
                    ForEach(usedWords, id: \.self) { word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Restart", action: restartGame)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
