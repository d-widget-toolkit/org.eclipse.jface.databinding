/*******************************************************************************
 * Copyright (c) 2006, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/

module org.eclipse.jface.databinding.swt.ISWTObservableValue;
import org.eclipse.jface.databinding.swt.ISWTObservable;

import java.lang.all;

import org.eclipse.core.databinding.observable.value.IObservableValue;

/**
 * {@link IObservableValue} observing an SWT widget.
 * 
 * @since 1.1
 *
 */
public interface ISWTObservableValue : ISWTObservable, IObservableValue {

}
