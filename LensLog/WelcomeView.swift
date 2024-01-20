import SwiftUI

// Define a single page for the welcome screen
struct WelcomePageView: View {
	var text: String
	var bgColor: Color
	var showButton: Bool = false
	var buttonAction: () -> Void = {}
	
	var body: some View {
		ZStack {
			// Set the background color based on the input
			bgColor.edgesIgnoringSafeArea(.all)

			// Place the text in the middle of the screen
			Text(text)
				.font(.largeTitle) // You can adjust the font size as needed
				.fontWeight(.bold)
				.foregroundColor(.white) // Set the text color to white
		
			if showButton {
				Button("Enter") {
					buttonAction()
				}
				.padding()
				.background(Color.white)
				.foregroundColor(bgColor)
				.cornerRadius(10)
				.padding()
			}
			
		}
		
	}
}

// WelcomeView is now a swipeable set of pages
struct WelcomeView: View {
	@State private var showHomePage = false
	
	var body: some View {
		if showHomePage {
			HomePageView() // Replace with your actual home page view
		} else {
			TabView {
				WelcomePageView(text: "LensLog", bgColor: .blue)
				WelcomePageView(text: "Capture Moments", bgColor: .green)
				WelcomePageView(text: "Create Memories", bgColor: .purple, showButton: true) {
					showHomePage = true
				}
			}
			.tabViewStyle(PageTabViewStyle())
			.indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
			.edgesIgnoringSafeArea(.all) // Ignore safe area for the entire TabView
		}
	}
}


// Preview for SwiftUI views
struct WelcomeView_Previews: PreviewProvider {
	static var previews: some View {
		WelcomeView()
	}
}
