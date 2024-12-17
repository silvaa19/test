import UIKit

// Delegate to pass selected data back to EntriesListViewController
protocol PickerViewControllerDelegate: AnyObject {
    func didSelectDate(_ date: Date, forRow row: Int)
    func didSelectOffice(_ office: String, forRow row: Int)
    func didSelectTime(_ time: Date, forRow row: Int, isTimeIn: Bool)
}

class PickerViewController: UIViewController {

    // Outlets for pickers
    @IBOutlet weak var datePicker: UIDatePicker!      // This will be used for date selection (just date)
    @IBOutlet weak var timePicker: UIDatePicker!      // This will be used for time selection (time in/out)
    @IBOutlet weak var pickerView: UIPickerView!      // This will be used for office selection
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!

    var isDatePickerMode: Bool = true        // Flag to determine if it's a date picker
    var isTimePickerMode: Bool = false       // Flag to determine if it's a time picker
    var isTimeInPicker: Bool = true          // To check whether it's time in or time out picker
    var officeList: [String] = []            // List of offices for selection
    var selectedRow: Int?                    // Row in the table that we are editing
    weak var delegate: PickerViewControllerDelegate? // Delegate to pass selected data back

    override func viewDidLoad() {
        super.viewDidLoad()

        // Show or hide the appropriate picker
        pickerView.isHidden = isDatePickerMode || isTimePickerMode
        datePicker.isHidden = !isDatePickerMode
        timePicker.isHidden = !isTimePickerMode
        
        // Configure pickerView if it's for office selection
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Set the date picker modes
        if isDatePickerMode {
            datePicker.datePickerMode = .date
        } else if isTimePickerMode {
            timePicker.datePickerMode = .time
        }
    }
    
    // Action for cancel button
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    // Action for select button
    @IBAction func selectAction(_ sender: UIButton) {
        guard let row = selectedRow else { return }

        if isDatePickerMode {
            // If we're using the date picker (for selecting dates)
            delegate?.didSelectDate(datePicker.date, forRow: row)
        } else if isTimePickerMode {
            // If we're using the time picker (for selecting time)
            delegate?.didSelectTime(timePicker.date, forRow: row, isTimeIn: isTimeInPicker)
        } else {
            // If we're using the picker view (for selecting offices)
            let selectedOffice = officeList[pickerView.selectedRow(inComponent: 0)]
            delegate?.didSelectOffice(selectedOffice, forRow: row)
        }

        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIPickerView DataSource & Delegate for Office Selection
extension PickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Only one component for the list of offices
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return officeList.count // Number of rows based on the office list
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return officeList[row] // Display the office names in the picker
    }
}
