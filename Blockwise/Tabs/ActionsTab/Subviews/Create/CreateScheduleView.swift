//
//  CreateScheduleView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 09/02/26.
//

import SwiftUI

struct CreateScheduleView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var vm = CreateScheduleViewModel()
    
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var actionsViewModel: ActionsViewModel
    
    let schedules: FetchedResults<ScheduleEntity>
    let template: ScheduleTemplate?
    
    init(schedules: FetchedResults<ScheduleEntity>, template: ScheduleTemplate? = nil) {
        self.schedules = schedules
        self.template = template
    }
    
    private let characterLimit = 20
    private var isNameValid: Bool {
        vm.name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }
    
    @FocusState private var isEmojiFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 10) {
                        Button {
                            isEmojiFieldFocused = true
                        } label: {
                            Text(vm.emoji)
                                .font(.system(size: 56))
                                .padding(18)
                                .background {
                                    Circle()
                                        .foregroundStyle(Color.secondary.opacity(0.1))
                                        .border(cornerRadius: 1000)
                                }
                        }
                        
                        // Hidden emoji text field
                        EmojiTextField(text: $vm.emoji)
                            .frame(width: 0, height: 0)
                            .opacity(0)
                            .focused($isEmojiFieldFocused)

                        CustomTextField()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(24)
                    .background {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .foregroundStyle(Theme.foregroundC)
                            .border(cornerRadius: 28)
                    }
                    
                    VStack(spacing: 18) {
                        
                        Button {
                            vm.showStartTimePicker = true
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 0) {
                                    Text("Start Time")
                                        .font(.grotesk(.title3, weight: .semibold))
                                        .foregroundStyle(.textC)
                                    
                                    Spacer()
                                    
                                    Text(vm.startTime.formatted(date: .omitted, time: .shortened))
                                        .font(.grotesk(.body, weight: .regular))
                                        .foregroundStyle(.secondary)
                                        .contentTransition(.numericText())
                                        .animation(.smooth, value: vm.startTime)
                                }
                            }
                            .padding(.trailing, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .overlay(alignment: .trailing) {
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .padding(24)
                            .background {
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .foregroundStyle(Theme.foregroundC)
                                    .border(cornerRadius: 28)
                            }
                        }
                        .tint(.primary)
                        
                        Button {
                            vm.showEndTimePicker = true
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 0) {
                                    Text("End Time")
                                        .font(.grotesk(.title3, weight: .semibold))
                                        .foregroundStyle(.textC)
                                    
                                    Spacer()
                                    
                                    Text(vm.endTime.formatted(date: .omitted, time: .shortened))
                                        .font(.grotesk(.body, weight: .regular))
                                        .foregroundStyle(.secondary)
                                        .contentTransition(.numericText())
                                        .animation(.smooth, value: vm.startTime)
                                }
                            }
                            .padding(.trailing, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .overlay(alignment: .trailing) {
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .padding(24)
                            .background {
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .foregroundStyle(Theme.foregroundC)
                                    .border(cornerRadius: 28)
                            }
                        }
                        .tint(.primary)
                        
                        weekdaysPicker
                    }
                    
                    Button {
                        vm.showFamilyPicker = true
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 0) {
                                Text("Block List")
                                    .font(.grotesk(.title3, weight: .semibold))
                                    .foregroundStyle(.textC)
                                
                                Spacer()
                                
                                Text("\(vm.familySelection.applicationTokens.count) apps")
                                    .font(.grotesk(.body, weight: .regular))
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                                    .animation(.smooth, value: vm.startTime)
                            }
                        }
                        .padding(.trailing, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(alignment: .trailing) {
                            Image(systemName: "chevron.right")
                                .font(.system(.subheadline, weight: .semibold))
                                .foregroundStyle(.secondary.opacity(0.5))
                        }
                        .padding(24)
                        .background {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .foregroundStyle(Theme.foregroundC)
                                .border(cornerRadius: 28)
                        }
                    }
                    .tint(.primary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .background {
                Theme.backgroundC.ignoresSafeArea(.keyboard, edges: .all)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26.0, *) {
                        Button {
                            action()
                        } label: {
                            let checkSize: CGFloat = 42.0
                            
                            CheckmarkShape(trimEnd: 1.0)
                                .trim(from: 0.0, to: 1.0)
                                .stroke(
                                    .white,
                                    style: StrokeStyle(
                                        lineWidth: checkSize / 12,
                                        lineCap: .round,
                                        lineJoin: .round
                                    )
                                )
                                .frame(square: checkSize / 2.0)
                        }
                        .buttonStyle(.glassProminent)
                    } else {
                        Button {
                            action()
                        } label: {
                            Image(systemName: "checkmark")
                        }
                        .tint(.blue)
                    }
                }
            }
            .sheet(isPresented: $vm.showStartTimePicker) {
                StartTimePicker()
                    .presentationDetents([.height(400)])
            }
            .sheet(isPresented: $vm.showEndTimePicker) {
                EndTimePicker()
                    .presentationDetents([.height(400)])
            }
            .sheet(isPresented: $vm.showFamilyPicker) {
                FamilySchedulePicker()
                    .environmentObject(vm)
            }
            .alert(vm.alertTitle, isPresented: $vm.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.alertMessage)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Schedule")
            .onAppear(perform: setup)
        }
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            if let template {
                vm.name = template.name
                vm.emoji = template.emoji
                vm.startTime = template.startTime
                vm.endTime = template.endTime
                vm.daysActive = template.weekdays
            }
        }
    }
    
    private func action() {
        do {
            try vm.createSchedule(schedules: schedules)
            dismiss()
            toastManager.info("Schedule created!")
            
            if let template {
                // Remove template
                actionsViewModel.hideTemplate(template)
            }
        } catch let error as ScheduleError {
            vm.alertTitle = error.title
            vm.alertMessage = error.message(for: vm.name.isEmpty ? "New Schedule" : vm.name)
            vm.showAlert = true
        } catch {
            vm.alertTitle = "Error"
            vm.alertMessage = "An unexpected error occurred."
            vm.showAlert = true
        }
    }
    
    @ViewBuilder
    private func StartTimePicker() -> some View {
        NavigationStack {
            VStack(spacing: 32) {
                DatePicker("", selection: $vm.startTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
            .safeAreaInset(edge: .bottom) {
                GlassButton("Done") {
                    vm.showStartTimePicker = false
                }
                .padding()
                .padding(.horizontal, 32)
            }
            .navigationTitle("Start Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.showStartTimePicker = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func EndTimePicker() -> some View {
        NavigationStack {
            VStack(spacing: 32) {
                DatePicker("", selection: $vm.endTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
            .safeAreaInset(edge: .bottom) {
                GlassButton("Done") {
                    vm.showEndTimePicker = false
                }
                .padding()
                .padding(.horizontal, 32)
            }
            .navigationTitle("End Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.showEndTimePicker = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
        }
    }

    @ViewBuilder
    private var weekdaysPicker: some View {
        VStack(spacing: 24) {
            HStack(spacing: 0) {
                Text("On these days")
                    .font(.grotesk(.title3, weight: .semibold))
                    .foregroundStyle(.textC)
                
                Spacer()
                
                Text("\(vm.daysActive.count) days")
                    .font(.grotesk(.body, weight: .regular))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                    .animation(.smooth, value: vm.startTime)
            }

            HStack(spacing: 0) {
                ForEach(Weekday.allCases, id: \.self) { weekday in
                    let isSelected = vm.daysActive.contains(weekday)
                    
                    Button {
                        vm.addRemove(weekday)
                    } label: {
                        Text(weekday.rawValue.prefix(1).uppercased())
                            .font(.grotesk(size: 17.5, weight: .semibold))
                            .frame(height: 40)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(isSelected ? .skyBlue : .secondary.opacity(0.15), in: .circle)
                    }
                    .tint(isSelected ? .white : .textC)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .foregroundStyle(Theme.foregroundC)
                .border(cornerRadius: 28)
        }

    }
    
    @ViewBuilder
    private func CustomTextField() -> some View {
        let cornerRadius: CGFloat = 100
        let height: CGFloat = 60
        
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .frame(height: height)
            .foregroundStyle(Color.secondary.opacity(0.1))
            .border(cornerRadius: cornerRadius)
            .overlay {
                TextField(text: $vm.name) {
                    Text("New Schedule")
                        .font(.grotesk(size: 18.5, weight: .semibold))
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .font(.grotesk(size: 18.5, weight: .semibold))
                .autocapitalization(.words)
                .onChange(of: vm.name) {
                    if vm.name.count > characterLimit {
                        vm.name = String(vm.name.prefix(characterLimit))
                    }
                }
                .overlay(alignment: .trailing) {
                    Button {
                        vm.name = ""
                        Haptics.feedback(style: .soft)
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.secondary.opacity(0.6))
                    }
                    .padding(.horizontal, 22)
                    .opacity(vm.name.isEmpty ? 0 : 1)
                }
                .padding(.vertical)
            }
    }
}

struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextField
        
        init(_ parent: EmojiTextField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Allow backspace/delete
            if string.isEmpty {
                return true
            }
            
            // Only allow emojis
            guard string.isSingleEmoji else {
                return false
            }
            
            // Replace the entire text with the new emoji (only 1 emoji allowed)
            DispatchQueue.main.async {
                self.parent.text = string
                // Resign first responder to close keyboard
                if let textField = textField as? EmojiOnlyTextField {
                    textField.resignFirstResponder()
                }
            }
            return false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> EmojiOnlyTextField {
        let textField = EmojiOnlyTextField()
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        return textField
    }
    
    func updateUIView(_ uiView: EmojiOnlyTextField, context: Context) {
        uiView.text = text
    }
}

// Custom UITextField that forces emoji keyboard
class EmojiOnlyTextField: UITextField {
    
    override var textInputMode: UITextInputMode? {
        // Try to get emoji keyboard
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return super.textInputMode
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupKeyboard()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupKeyboard()
    }
    
    private func setupKeyboard() {
        // This encourages the system to start with emoji keyboard
        autocorrectionType = .no
        spellCheckingType = .no
        autocapitalizationType = .none
    }
}

extension String {
    var isSingleEmoji: Bool {
        guard count == 1, let character = first else {
            return false
        }
        return character.isEmoji
    }
}

extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else {
            return false
        }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}

#Preview {
    CreateScheduleViewPreview()
        .environmentObject(ToastManager())
        .environmentObject(ActionsViewModel())
}

private struct CreateScheduleViewPreview: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScheduleEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var schedules: FetchedResults<ScheduleEntity>

    var body: some View {
        CreateScheduleView(schedules: schedules)
    }
}
