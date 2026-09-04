//
//  WidgetWelcome.swift
//  prayerbook
//
//  First-launch welcome for 6.5.0 announcing the home-screen calendar widget.
//

import SwiftUI
import UIKit
import swift_toolkit

final class WidgetWelcomeViewController: UIViewController, PopupContentViewController {
    private var host: UIHostingController<WidgetWelcomeContent>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#FFEBCD")

        let content = WidgetWelcomeContent {
            UIViewController.popup.dismiss()
        }
        let hosting = UIHostingController(rootView: content)
        hosting.view.backgroundColor = .clear
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hosting.didMove(toParent: self)
        host = hosting
    }

    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        let width = min(size.width - 32, 340)
        return CGSize(width: width, height: 480)
    }
}

struct WidgetWelcomeContent: View {
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("Молитвослов 6.5")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.black)
                .multilineTextAlignment(.center)

            Text("На домашний экран добавлен виджет православного календаря: день, пост и память святых — без открытия приложения.")
                .font(.system(size: 14))
                .foregroundStyle(Color(white: 0.2))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            AddWidgetTutorialAnimation()
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )

            Button(action: onClose) {
                Text("Понятно")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(white: 0.25))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color(white: 0.35), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(Color(uiColor: UIColor(hex: "#FFEBCD")))
    }
}

/// Schematic looping demo: long-press home screen → «+» → pick widget → widget appears.
private struct AddWidgetTutorialAnimation: View {
    private enum Step: Int, CaseIterable {
        case home
        case longPress
        case editMode
        case gallery
        case placed
    }

    @State private var step: Step = .home

    private var caption: String {
        switch step {
        case .home: return "Домашний экран"
        case .longPress: return "Удерживайте палец на экране"
        case .editMode: return "Нажмите «+» в углу"
        case .gallery: return "Выберите «Молитвослов»"
        case .placed: return "Виджет появится на экране"
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Color(white: 0.93)

                phoneChrome
                    .padding(.horizontal, 48)
                    .padding(.vertical, 18)

                if step == .longPress {
                    longPressHint
                }
            }

            Text(caption)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(white: 0.25))
                .multilineTextAlignment(.center)
                .animation(nil, value: step)
        }
        .task { await runLoop() }
    }

    private var phoneChrome: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color(white: 0.16))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(white: 0.97))
                    .padding(7)
                    .overlay(homeContents.padding(14))
            )
            .aspectRatio(0.55, contentMode: .fit)
    }

    @ViewBuilder
    private var homeContents: some View {
        VStack(spacing: 10) {
            HStack {
                if step == .editMode || step == .gallery {
                    plusBadge
                        .scaleEffect(step == .editMode ? 1.12 : 1.0)
                        .animation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true), value: step)
                } else {
                    Color.clear.frame(width: 22, height: 22)
                }
                Spacer()
            }

            if step == .gallery {
                widgetGalleryCard
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            } else {
                iconGrid(jiggling: step == .editMode || step == .gallery)
                if step == .placed {
                    calendarWidgetCard
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    Spacer(minLength: 0)
                }
            }

            Spacer(minLength: 0)
        }
        .animation(.easeInOut(duration: 0.35), value: step)
    }

    private var plusBadge: some View {
        ZStack {
            Circle().fill(Color(white: 0.88))
            Image(systemName: "plus")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.black)
        }
        .frame(width: 22, height: 22)
    }

    private func iconGrid(jiggling: Bool) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<8, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconColor(index))
                    .aspectRatio(1, contentMode: .fit)
                    .rotationEffect(.degrees(jiggling ? (index.isMultiple(of: 2) ? -3 : 3) : 0))
                    .animation(
                        jiggling
                            ? .easeInOut(duration: 0.18).repeatForever(autoreverses: true).delay(Double(index) * 0.03)
                            : .default,
                        value: jiggling
                    )
            }
        }
    }

    private func iconColor(_ index: Int) -> Color {
        let palette: [Color] = [
            Color(red: 0.35, green: 0.55, blue: 0.85),
            Color(red: 0.85, green: 0.45, blue: 0.35),
            Color(red: 0.40, green: 0.70, blue: 0.50),
            Color(red: 0.90, green: 0.70, blue: 0.30),
            Color(red: 0.55, green: 0.45, blue: 0.80),
            Color(red: 0.30, green: 0.70, blue: 0.75),
            Color(red: 0.75, green: 0.40, blue: 0.55),
            Color(red: 0.45, green: 0.45, blue: 0.50),
        ]
        return palette[index % palette.count]
    }

    private var calendarWidgetCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("30/17 сент.")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.black)
            Text("Растительная пища")
                .font(.system(size: 9).italic())
                .foregroundStyle(Color(white: 0.35))
            Text("Свт. …")
                .font(.system(size: 9))
                .foregroundStyle(Color.black.opacity(0.8))
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color(red: 0.19, green: 0.84, blue: 0.78).opacity(0.7), lineWidth: 1.5)
        )
    }

    private var widgetGalleryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Виджеты")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.black)
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(red: 0.75, green: 0.2, blue: 0.2))
                    .frame(width: 28, height: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Молитвослов")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.black)
                    Text("Православный календарь")
                        .font(.system(size: 9))
                        .foregroundStyle(Color(white: 0.4))
                }
                Spacer(minLength: 0)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.95, blue: 0.88))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.red.opacity(0.45), lineWidth: 1.5)
                    )
            )
            calendarWidgetCard
                .scaleEffect(0.92)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.95))
        )
    }

    private var longPressHint: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.35), lineWidth: 2)
                .frame(width: 54, height: 54)
                .scaleEffect(step == .longPress ? 1.25 : 0.8)
                .opacity(step == .longPress ? 0.15 : 0.5)
                .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: step)

            Image(systemName: "hand.tap.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.blue.opacity(0.85))
                .offset(y: 8)
        }
    }

    private func runLoop() async {
        while !Task.isCancelled {
            for next in Step.allCases {
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.35)) {
                    step = next
                }
                let delay: UInt64 = next == .placed ? 1_600_000_000 : 1_150_000_000
                try? await Task.sleep(nanoseconds: delay)
            }
        }
    }
}
