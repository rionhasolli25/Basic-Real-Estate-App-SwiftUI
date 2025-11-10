//
//  MortgageCalculatorView.swift
//  RealEstateApp
//
//  Created by Rion on 30.10.25.
//

import SwiftUI

struct MortgageCalculatorView: View {
    @State private var homePrice: String = ""
    @State private var downPayment: String = ""
    @State private var interestRate: String = ""
    @State private var loanTerm: String = ""
    
    @State private var monthlyPayment: Double?
       
    
    var body: some View {
        NavigationView{
            ZStack{
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.4),Color.green.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                ScrollView{
                    VStack(spacing:10){
                        Text("🏠 Mortgage Calculator")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                    }
                    VStack(spacing: 15) {
                        CustomTextField(title: "Home Price (€)", text: $homePrice)
                        CustomTextField(title: "Down Payment (€)", text: $downPayment)
                        CustomTextField(title: "Interest Rate (%)", text: $interestRate)
                        CustomTextField(title: "Loan Term (Years)", text: $loanTerm)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                    
                    Button(action: calculateMortage) {
                        Text("Calculate")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    if let payment = monthlyPayment{
                        VStack(spacing: 10) {
                            Text("Estimated Monthly Payment:")
                                .font(.headline)
                            Text("€\(String(format: "%.2f", payment))")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                        .transition(.opacity)
                    }
                    
                    Spacer()
                        .padding(.vertical)
                }
            }
        }
    }
    private func calculateMortage(){
        guard let price = Double(homePrice),
         let down = Double(downPayment),
         let rate = Double(interestRate),
        let years = Double(loanTerm)
        else { return }
        
        let loanAmount = price - down
        let monthlyRate = rate/100 * 12
        let numberOfPayments = years * 12
        
        let payment = (loanAmount * monthlyRate) /
                              (1 - pow(1 + monthlyRate, -numberOfPayments))
                
        
        withAnimation{
            monthlyPayment = payment
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField(title, text: $text)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
        }
    }
}


#Preview {
    MortgageCalculatorView()
}
