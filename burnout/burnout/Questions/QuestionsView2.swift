//
//  QuestionsView2.swift
//  burnout
//
//  Created by Noura Alsbuayt on 17/08/1447 AH.
//

import SwiftUI
import SwiftData

//Observable == يراقب اي تغيرات ويتحدث تلقائيا

@Observable class QuestionsView2 {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var sliderValue: Double = 3
    @State private var isSubmitting = false
    
    private var sliderText: String{
        switch Int(sliderValue)
        {
        case 1: return "Never"
        case 2: return " A Little"
        case 3: return "Somewhat"
        case 4: return "A Lot"
        case 5: return "Extremely"
        default: return "Somewhat"

        }
    }
    
    
    
    var body: some View {
        
        Zstack{
            
        }
    }

    
}
