import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            TabView {
                WeatherView()
                    .tabItem {
                        Label("Weather", systemImage: "sun.max.fill")
                    }
                
                LocationView()
                    .tabItem {
                        Label("Location", systemImage: "map.fill")
                    }
            }
        }.navigationTitle("Weather ☁️")
    }
}

struct LocationView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            if let coordinate = locationManager.lastKnownLocation {
                Text("Latitude: \(coordinate.latitude)")
                Text("Longitude: \(coordinate.longitude)")
            }
            
            
            Button("Get location") {
                locationManager.checkLocationAuthorization()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct WeatherView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var weatherData: Weather?
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Button("Get Weather Data") {
                if let coordinate = locationManager.lastKnownLocation {
                    print("Coordinate found: \(coordinate.latitude), \(coordinate.longitude)")
                    fetchWeatherData()
                } else {
                    print("No location available")
                    errorMessage = "Please get location first"
                }
            }
            .buttonStyle(.borderedProminent)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if let weatherData = weatherData {
                VStack(spacing: 10) {
                    Text("Current Weather Data:")
                        .font(.headline)
                    Text("Temperature: \(weatherData.current.tempC, specifier: "%.1f")°C")
                    
                    Text("Condition: \(weatherData.current.condition.text)")
                }
                .padding()
            }
        }
        .onAppear {
            locationManager.checkLocationAuthorization()
        }
    }
    
    func fetchWeatherData() {
        guard let coordinate = locationManager.lastKnownLocation else {
            print("No coordinate available when fetching weather")
            errorMessage = "Location not available"
            return
        }
        
        let urlString = "https://api.weatherapi.com/v1/current.json?key=421805ff26514555878144056250202&q=\(coordinate.latitude),\(coordinate.longitude)"
        print("Fetching weather from URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            DispatchQueue.main.async {
                guard let data = data else {
                    print("No data received")
                    errorMessage = "No data received"
                    return
                }
                
                do {
                    let weather = try JSONDecoder().decode(Weather.self, from: data)
                    self.weatherData = weather
                    self.errorMessage = nil
                    print("Data decoded successfully")
                    print("Temperature: \(weather.current.tempC)°C")
                } catch {
                    print("Decoding error: \(error)")
                    errorMessage = "Decoding error: \(error.localizedDescription)"
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("Received JSON: \(dataString)")
                    }
                }
            }
        }.resume()
    }
}

struct Weather: Codable {
    let location: Location
    let current: Current
}

struct Current: Codable {
    let lastUpdatedEpoch: Int
    let lastUpdated: String
    let tempC: Double
    let tempF: Double
    let isDay: Int
    let condition: Condition
    let windMph: Double
    let windKph: Double
    let windDegree: Int
    let windDir: String
    let pressureMb: Double
    let pressureIn: Double
    let precipMm: Double
    let precipIn: Double
    let humidity: Int
    let cloud: Int
    let feelslikeC: Double
    let feelslikeF: Double
    let visKm: Double
    let visMiles: Double
    let uv: Double
    let gustMph: Double
    let gustKph: Double

    enum CodingKeys: String, CodingKey {
        case lastUpdatedEpoch = "last_updated_epoch"
        case lastUpdated = "last_updated"
        case tempC = "temp_c"
        case tempF = "temp_f"
        case isDay = "is_day"
        case condition
        case windMph = "wind_mph"
        case windKph = "wind_kph"
        case windDegree = "wind_degree"
        case windDir = "wind_dir"
        case pressureMb = "pressure_mb"
        case pressureIn = "pressure_in"
        case precipMm = "precip_mm"
        case precipIn = "precip_in"
        case humidity, cloud
        case feelslikeC = "feelslike_c"
        case feelslikeF = "feelslike_f"
        case visKm = "vis_km"
        case visMiles = "vis_miles"
        case uv
        case gustMph = "gust_mph"
        case gustKph = "gust_kph"
    }
}

struct Condition: Codable {
    let text: String
    let icon: String
    let code: Int
}

struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let tzId: String
    let localtimeEpoch: Int
    let localtime: String

    enum CodingKeys: String, CodingKey {
        case name, region, country, lat, lon
        case tzId = "tz_id"
        case localtimeEpoch = "localtime_epoch"
        case localtime
    }
}

#Preview {
    ContentView()
}
