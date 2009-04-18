/*******************************************************************************
 * Copyright (c) 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 ******************************************************************************/

module org.eclipse.jface.databinding.viewers.IViewerObservableValue;
import org.eclipse.jface.databinding.viewers.IViewerObservable;

import java.lang.all;

import org.eclipse.core.databinding.observable.value.IObservableValue;

/**
 * {@link IObservableValue} observing a JFace Viewer.
 * 
 * @since 1.2
 * 
 */
public interface IViewerObservableValue : IObservableValue,
        IViewerObservable {
}
