import SwiftUI
import Combine

class WelcomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var name: String = ""
    @Published var currentPage: Int = 1
    @Published var selectedDays: Set<String> = []
    @Published var workEndTime = Date()
    
    // MARK: - Computed Properties
    var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var canProceedToNextPage: Bool {
        isNameValid
    }
    
    var hasSelectedDays: Bool {
        !selectedDays.isEmpty
    }
    
    var canCompleteOnboarding: Bool {
        hasSelectedDays
    }
    
    // MARK: - Actions
    func goToNextPage() {
        withAnimation {
            currentPage = 2
        }
    }
    
    func goToPreviousPage() {
        withAnimation {
            currentPage = 1
        }
    }
    
    func toggleDay(_ day: String) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
    
    func completeOnboarding() {
        // Save user data
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(Array(selectedDays), forKey: "workDays")
        UserDefaults.standard.set(workEndTime, forKey: "workEndTime")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        print("Onboarding completed for \(name)")
        print("Work days: \(selectedDays)")
        print("Work end time: \(workEndTime)")
    }
}
