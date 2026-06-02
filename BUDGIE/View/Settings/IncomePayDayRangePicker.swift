import SwiftUI

struct IncomePayDayRangePicker: View {
    @Binding var fromDay: Int
    @Binding var toDay: Int
    
    var fromLabel: LocalizedStringKey = "From Day"
    var toLabel: LocalizedStringKey = "To Day"
    
    private let wheelWidth: CGFloat = 140
    private let wheelHeight: CGFloat = 130
    
    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            VStack(alignment: .center, spacing: 6) {
                Text(fromLabel)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Picker("", selection: $fromDay) {
                    ForEach(1...31, id: \.self) { day in
                        Text("\(day)")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .tag(day)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .frame(width: wheelWidth, height: wheelHeight)
                .clipped()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(alignment: .center, spacing: 6) {
                Text(toLabel)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Picker("", selection: $toDay) {
                    ForEach(1...31, id: \.self) { day in
                        Text("\(day)")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .tag(day)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .frame(width: wheelWidth, height: wheelHeight)
                .clipped()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .onChange(of: fromDay) { _, newValue in
            // Keep the picker logically valid: from <= to.
            if newValue > toDay {
                toDay = newValue
            }
        }
        .onChange(of: toDay) { _, newValue in
            if newValue < fromDay {
                fromDay = newValue
            }
        }
    }
}

#Preview {
    struct Wrapper: View {
        @State var fromDay: Int = 27
        @State var toDay: Int = 31
        
        var body: some View {
            IncomePayDayRangePicker(fromDay: $fromDay, toDay: $toDay)
                .padding()
        }
    }
    
    return Wrapper()
}

