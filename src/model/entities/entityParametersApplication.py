class ParametersApplication:
    def __init__(self, tecnologyDatastoreSource, tecnologyDatastoreDestiny, structureFieldsDataframeSource, dateField, dateFieldValueDefault, dateFieldValue, dateFieldFormat,
                 dayWeekField, dayWeekFieldValue, priceField, headersBrowser, singleSourceTransferency, singleDestinyTransferency):
        self.__tecnologyDatastoreSource = tecnologyDatastoreSource
        self.__tecnologyDatastoreDestiny = tecnologyDatastoreDestiny
        self.__structureFieldsDataframeSource = structureFieldsDataframeSource
        self.__dateField = dateField
        self.__dateFieldValueDefault = dateFieldValueDefault
        self.__dateFieldValue = dateFieldValue
        self.__dateFieldFormat = dateFieldFormat
        self.__dayWeekField = dayWeekField
        self.__dayWeekFieldValue = dayWeekFieldValue
        self.__priceField = priceField
        self.__headersBrowser = headersBrowser
        self.__singleSourceTransferency = singleSourceTransferency
        self.__singleDestinyTransferency = singleDestinyTransferency

    @property
    def tecnologyDatastoreSource(self):
        return self.__tecnologyDatastoreSource

    @property
    def tecnologyDatastoreDestiny(self):
        return self.__tecnologyDatastoreDestiny

    @property
    def structureFieldsDataframeSource(self):
        return self.__structureFieldsDataframeSource

    @property
    def dateField(self):
        return self.__dateField

    @property
    def dateFieldValueDefault(self):
        return self.__dateFieldValueDefault

    @property
    def dateFieldValue(self):
        return self.__dateFieldValue

    @property
    def dateFieldFormat(self):
        return self.__dateFieldFormat

    @property
    def dayWeekField(self):
        return self.__dayWeekField

    @property
    def dayWeekFieldValue(self):
        return self.__dayWeekFieldValue

    @property
    def priceField(self):
        return self.__priceField

    @property
    def headersBrowser(self):
        return self.__headersBrowser

    @property
    def singleSourceTransferency(self):
        return self.__singleSourceTransferency

    @property
    def singleDestinyTransferency(self):
        return self.__singleDestinyTransferency

    @dateFieldValue.setter
    def dateFieldValue(self, value):
        self.__dateFieldValue = value

    @dayWeekFieldValue.setter
    def dayWeekFieldValue(self, value):
        self.__dayWeekFieldValue = value
